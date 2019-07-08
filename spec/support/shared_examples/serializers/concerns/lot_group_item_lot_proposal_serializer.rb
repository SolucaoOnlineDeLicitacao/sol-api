RSpec.shared_examples "a lot_group_item_lot_proposal_serializer" do
  let(:object) { create :lot_group_item_lot_proposal }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'price' => object.price }
    it { is_expected.to include '_destroy' => object._destroy }
  end

  describe 'associations' do
    describe 'lot_group_item' do
      let(:serialized_lot_group_item) do
        format_json(::Coop::LotGroupItemSerializer, object.lot_group_item)
      end

      it { is_expected.to include 'lot_group_item' => serialized_lot_group_item }
    end
  end
end
