RSpec.shared_examples "a group_serializer" do
  let(:object) { create :group }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:total_expected_value) do
      total = 0
      object.group_items.map{ |group_item| total += group_item.estimated_cost * group_item.quantity }
      total
    end

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'group_items_count' => object.group_items_count }
    it { is_expected.to include 'group_items_value_count' => total_expected_value.to_s }
  end

  describe 'associations' do
    describe 'group_items' do
      before { create(:group_item, group: object) }

      let(:serialized_group_items) do
        object.group_items.map do |group_item|
          format_json(Administrator::GroupItemSerializer, group_item)
        end
      end

      it { is_expected.to include 'group_items' => serialized_group_items }
    end
  end
end
