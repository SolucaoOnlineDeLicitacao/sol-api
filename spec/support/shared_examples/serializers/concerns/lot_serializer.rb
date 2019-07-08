RSpec.shared_examples "a lot_serializer" do
  let(:object) { create :lot }
  let(:supplier) { create(:supplier) }
  let(:provider) { supplier.provider }
  let(:proposals) { object.proposals.where(provider: provider) }

  let!(:lot_proposal_import) do
    create(:lot_proposal_import, lot: object, provider: provider,
      bidding: object.bidding)
  end

  let!(:proposal_import) do
    create(:lot_proposal_import,  provider: provider, bidding: object.bidding)
  end

  subject { format_json(described_class, object, scope: supplier) }

  describe 'attributes' do
    let(:lot_proposals) do
      proposals.map(&:lot_proposals)&.flatten
    end

    let(:pending) do
      ::Policies::Bidding::InvitePolicy.new(object.bidding, provider).pending?
    end

    let(:invited) do
      ::Policies::Bidding::InvitePolicy.new(object.bidding, provider).allowed?
    end

    let(:abandoned_proposal) do
      object.bidding.proposals.where(provider: provider).abandoned.any?
    end

    let(:proposal_importing) do
      object.lot_proposal_imports.where(provider: provider).active.any?
    end

    let(:global_proposal_importing) do
      object.bidding.proposal_imports.where(provider: provider).active.any?
    end

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => "#{object.position} - #{object.name}" }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'bidding_title' => object.bidding.title }
    it { is_expected.to include 'bidding_status' => object.bidding.status }
    it { is_expected.to include 'bidding_kind' => object.bidding.kind }
    it { is_expected.to include 'bidding_modality' => object.bidding.modality }
    it { is_expected.to include 'bidding_draw_at' => I18n.l(object.bidding.draw_at) }
    it { is_expected.to include 'lot_group_items_count' => object.lot_group_items_count }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'deadline' => object.deadline }
    it { is_expected.to include 'address' => object.address }
    it { is_expected.to include 'lot_proposals' => lot_proposals }
    it { is_expected.to include 'proposal_status' => proposals.first&.status }
    it { is_expected.to include 'proposal_price_total' => proposals.first&.price_total }
    it { is_expected.to include 'pending' => pending }
    it { is_expected.to include 'invited' => invited }
    it { is_expected.to include 'abandoned_proposal' => abandoned_proposal }
    it { is_expected.to include 'proposal_importing' => proposal_importing }
    it { is_expected.to include 'global_proposal_importing' => global_proposal_importing }
    it { is_expected.to include 'position' => object.position }
    it { is_expected.to include 'lot_proposal_import_file_url' => object.lot_proposal_import_file&.url }
    it { is_expected.to include 'bidding_proposal_import_file_url' => object.bidding.proposal_import_file&.url }
    it { expect(subject['provider']['id']).to eq provider.id }
  end

  describe 'associations' do
    describe 'lot_group_items' do
      before { create(:lot_group_item, lot: object) }

      let(:serialized_lot_group_items) do
        object.lot_group_items.map do |lot_group_item|
          format_json(Supp::LotGroupItemSerializer, lot_group_item)
        end
      end

      it { is_expected.to include 'lot_group_items' => serialized_lot_group_items }
    end

    describe 'attachments' do
      let(:serialized_attachments) do
        object.attachments.map { |attachment| format_json(AttachmentSerializer, attachment) }
      end

      it { is_expected.to include 'attachments' => serialized_attachments }
    end
  end
end
