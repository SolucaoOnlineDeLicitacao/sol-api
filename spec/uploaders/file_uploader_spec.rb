require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe FileUploader do
  include CarrierWave::Test::Matchers

  let(:document) { create(:document) }
  let(:uploader) { described_class.new(document, :file) }
  let(:filepath) { File.join(Rails.root, "/spec/fixtures/myfiles/file.pdf") }

  before do
    described_class.enable_processing = true
    subject
  end

  subject { File.open(filepath) { |f| uploader.store!(f) } }

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  context 'when permission is 0644' do
    it { expect(uploader).to have_permissions(0644) }
  end

end
