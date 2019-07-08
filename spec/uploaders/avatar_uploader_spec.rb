require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe AvatarUploader do
  include CarrierWave::Test::Matchers

  before { described_class.enable_processing = true }

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  describe 'User' do
    let(:uploader) { described_class.new(user, :avatar) }

    context 'when it is used default avatar image' do
      let(:user) { create(:user, avatar: nil) }

      subject { user.avatar.url }

      it { is_expected.to eq '/default_avatar.jpg' }
    end

    context 'when it is a avatar image' do
      let(:user) { create(:user) }
      let(:filepath) { File.join(Rails.root, "/spec/fixtures/myfiles/#{filename}") }

      subject { File.open(filepath) { |f| uploader.store!(f) } }

      context 'when the file type is a valid image' do
        let(:filename) { 'avatar.jpg' }

        before { subject }

        it { expect(uploader).to have_dimensions(60, 60) }
        
        context 'and is .jpg' do
          it { expect(uploader).to be_format('JPEG') }
        end

        context 'and is .jpeg' do
          let(:filename) { 'avatar.jpg' }

          it { expect(uploader).to be_format('JPEG') }
        end

        context 'and is .gif' do
          let(:filename) { 'avatar.gif' }

          it { expect(uploader).to be_format('GIF') }
        end

        context 'and is .png' do
          let(:filename) { 'avatar.png' }

          it { expect(uploader).to be_format('PNG') }
        end
      end

      context 'when the file type is not an image' do
        let(:filename) { 'file.pdf' }

        it do
          expect { subject }.to raise_error(
            CarrierWave::IntegrityError,
            'Não é permitido o envio de arquivos "pdf", '\
            'tipos permitidos: jpg, jpeg, gif, png'
          )
        end
      end

      context 'when the image is greater than 5 MB' do
        let(:filename) { 'huge_avatar.jpg' }

        it do
          expect { subject }.to raise_error(
            CarrierWave::IntegrityError,
            'O tamanho do arquivo deve ser inferior a 5 MB'
          )
        end
      end
    end
  end

  describe 'Supplier' do
    let(:uploader) { described_class.new(supplier, :avatar) }

    context 'when it is used default avatar image' do
      let(:supplier) { create(:supplier, avatar: nil) }

      subject { supplier.avatar.url }

      it { is_expected.to eq '/default_avatar.jpg' }
    end

    context 'when it is a avatar image' do
      let(:supplier) { create(:supplier) }
      let(:filepath) { File.join(Rails.root, "/spec/fixtures/myfiles/#{filename}") }

      subject { File.open(filepath) { |f| uploader.store!(f) } }

      context 'when the file type is a valid image' do
        let(:filename) { 'avatar.jpg' }

        before { subject }

        it { expect(uploader).to have_dimensions(60, 60) }
        
        context 'and is .jpg' do
          it { expect(uploader).to be_format('JPEG') }
        end

        context 'and is .jpeg' do
          let(:filename) { 'avatar.jpg' }

          it { expect(uploader).to be_format('JPEG') }
        end

        context 'and is .gif' do
          let(:filename) { 'avatar.gif' }

          it { expect(uploader).to be_format('GIF') }
        end

        context 'and is .png' do
          let(:filename) { 'avatar.png' }

          it { expect(uploader).to be_format('PNG') }
        end
      end

      context 'when the file type is not an image' do
        let(:filename) { 'file.pdf' }

        it do
          expect { subject }.to raise_error(
            CarrierWave::IntegrityError,
            'Não é permitido o envio de arquivos "pdf", '\
            'tipos permitidos: jpg, jpeg, gif, png'
          )
        end
      end

      context 'when the image is greater than 5 MB' do
        let(:filename) { 'huge_avatar.jpg' }

        it do
          expect { subject }.to raise_error(
            CarrierWave::IntegrityError,
            'O tamanho do arquivo deve ser inferior a 5 MB'
          )
        end
      end
    end
  end
end
