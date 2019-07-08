require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe DocumentUploader::Pdf do
  include CarrierWave::Test::Matchers

  let(:document) { create(:document) }
  let(:uploader) { described_class.new(document, :file) }
  let(:filepath) { File.join(Rails.root, "/spec/fixtures/myfiles/#{filename}") }

  before do
    described_class.enable_processing = true
  end

  subject { File.open(filepath) { |f| uploader.store!(f) } }

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  context 'when the file type is pdf' do
    let(:filename) { 'file.pdf' }

    it { expect(uploader).to be_instance_of(described_class) }
  end

  context 'when the file type is not pdf' do
    let(:filename) { 'test.html' }

    it do
      expect { subject }.to raise_error(
        CarrierWave::IntegrityError,
        'Não é permitido o envio de arquivos "html", tipos permitidos: pdf'
      )
    end
  end
end
