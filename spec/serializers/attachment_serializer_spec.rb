require 'rails_helper'

RSpec.describe AttachmentSerializer, type: :serializer do
  let(:object) { create :attachment }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'url' => object.file.url }
    it { is_expected.to include 'filename' => object.file.file.filename }
  end
end
