require 'rails_helper'

RSpec.describe Administrator::ReportSerializer, type: :serializer do
  let(:object) { create :report }
  let(:serializer) { described_class.new object }
  let(:serialized) { serializer.serializable_hash }

  subject { JSON.parse(serialized.to_json) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'admin_id' => object.admin.id }
    it { is_expected.to include 'admin_name' => object.admin.name }
    it { is_expected.to include 'report_type' => object.report_type }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'url' => object.url }
    it { is_expected.to include 'error_message' => object.error_message }
    it { is_expected.to include 'error_backtrace' => object.error_backtrace }
    it { is_expected.to include 'created_at' => object.created_at.strftime("%FT%T.%L%:z") }
  end
end
