RSpec.shared_examples "serializers/concerns/base_contracts_serializer" do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:provider) { create(:provider) }
  let(:supplier) { create(:supplier, provider: provider) }
  let(:document) { create(:document) }
  let(:object) do
    create(
      :contract, :full_signed_at,
      user: user, user_signed_at: DateTime.current,
      supplier: supplier, supplier_signed_at: DateTime.current,
      document: document
    )
  end
  let(:proposal) { object.proposal }
  let(:bidding) { proposal.bidding }

  let(:covenant_number_name) { "#{bidding.covenant.number} - #{bidding.covenant.name}" }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'title' => "#{object.id}/#{object.created_at.year}" }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'price_total' => object.proposal_price_total.to_f }
    it { is_expected.to include 'bidding_title' => object.bidding.title }
    it { is_expected.to include 'provider_title' => object.proposal.provider.name }
    it { is_expected.to include 'supplier_signed_at' => I18n.l(object.supplier_signed_at, format: :shorter) }
    it { is_expected.to include 'user_signed_at' => I18n.l(object.user_signed_at, format: :shorter) }
    it { is_expected.to include 'bidding_kind' => object.bidding.kind }
    it { is_expected.to include 'proposal_id' => object.proposal_id }
    it { is_expected.to include 'bidding_id' => object.bidding.id }
    it { is_expected.to include 'lot_proposal_ids' => object.proposal.lot_proposal_ids }
    it { is_expected.to include 'lot_ids' => object.proposal.lot_proposals.map(&:lot_id) }
    it { is_expected.to include 'refused_by_name' => object.refused_by.name }
    it { is_expected.to include 'refused_by_at' => I18n.l(object.refused_by_at, format: :shorter) }
    it { is_expected.to include 'refused_by_class' => object.refused_by.class.name.underscore }
    it { is_expected.to include 'covenant_name' => covenant_number_name }
    it { is_expected.to include 'deadline' => object.deadline }
    it { expect(subject['contract_pdf']).to include('file.pdf')}

    describe 'refused_comment' do
      let!(:change) do
        create(:event_contract_refused, from: 'waiting', to: 'refused',
          eventable: object, comment: 'Oh noes')
      end

      let(:event) do
        object.event_contract_refuseds&.last
      end

      it { is_expected.to include 'refused_comment' => event.comment }
    end

  end
end
