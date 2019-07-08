require 'rails_helper'

RSpec.describe AdditiveSerializer, type: :serializer do
  let(:object) { create :additive }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'from' => I18n.l(object.from) }
    it { is_expected.to include 'to' => I18n.l(object.to) }
  end
end
