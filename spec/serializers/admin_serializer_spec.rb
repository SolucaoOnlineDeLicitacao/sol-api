require 'rails_helper'

RSpec.describe AdminSerializer, type: :serializer do
  let(:object) { create :admin }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'email' => object.email }
    it { is_expected.to include 'role' => object.role }
  end

  describe 'associations' do
    describe 'covenants' do
      let!(:covenant) { create(:covenant, admin: object) }

      let(:serialized_covenants) { object.covenants.select(:id, :number, :name).as_json }

      it { is_expected.to include 'covenants' => serialized_covenants }
    end
  end

end
