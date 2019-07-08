RSpec.shared_examples "a covenant_serializer" do
  let(:object) { create :covenant }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:cooperative_address_city_name) do
      "#{object.cooperative.address_city_name} / #{object.cooperative.address_state_name}"
    end
    let(:number_name) { "#{object.number} - #{object.name}" }

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'title' => number_name }
    it { is_expected.to include 'number' => object.number }
    it { is_expected.to include 'estimated_cost' => object.estimated_cost }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'signature_date' => I18n.l(object.signature_date) }
    it { is_expected.to include 'validity_date' => I18n.l(object.validity_date) }
    it { is_expected.to include 'cooperative_id' => object.cooperative_id }
    it { is_expected.to include 'cooperative_name' => object.cooperative_name }
    it { is_expected.to include 'cooperative_address_city_name' => cooperative_address_city_name }
    it { is_expected.to include 'admin_id' => object.admin_id }
    it { is_expected.to include 'admin_name' => object.admin_name }
    it { is_expected.to include 'city_id' => object.city_id }
    it { is_expected.to include 'city_text' => object.city_text }
  end

  describe 'associations' do
    describe 'groups' do
      before { create(:group, covenant: object) }

      let(:serialized_groups) do
        object.groups.map do |group|
          format_json(Administrator::GroupSerializer, group).except("group_items")
        end
      end

      it { is_expected.to include 'groups' => serialized_groups }
    end
  end
end
