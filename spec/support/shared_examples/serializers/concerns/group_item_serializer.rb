RSpec.shared_examples "a group_item_serializer" do
  let(:object) { create :group_item }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'item_id' => object.item_id }
    it { is_expected.to include 'item_name' => object.item.text }
    it { is_expected.to include 'item_short_name' => object.item.title }
    it { is_expected.to include 'item_unit' => object.item.unit_name }
    it { is_expected.to include 'quantity' => object.quantity.to_s }
    it { is_expected.to include 'available_quantity' => object.available_quantity.to_s }
    it { is_expected.to include 'group_name' => object.group.name }
    it { is_expected.to include 'estimated_cost' => object.estimated_cost }
    it { is_expected.to include '_destroy' => object._destroy }
  end
end
