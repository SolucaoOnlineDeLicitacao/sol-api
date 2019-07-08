require 'rails_helper'

RSpec.describe EventProviderAccessSerializer, type: :serializer do
  let(:object) { create :event_provider_access }

  subject { format_json(described_class, object) }

  context 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'eventable_type' => object.eventable_type }
    it { is_expected.to include 'eventable_id' => object.eventable_id }
    it { is_expected.to include 'creator_type' => object.creator_type }
    it { is_expected.to include 'creator_id' => object.creator_id }
    it { is_expected.to include 'creator_name' => object.creator.name }
    it { is_expected.to include 'data' => object.data }
    it { is_expected.to include 'created_at' => object.created_at.strftime("%FT%T.%L%:z") }
  end
end
