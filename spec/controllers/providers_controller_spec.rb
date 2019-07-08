require 'rails_helper'

RSpec.describe ProvidersController, type: :controller do

  let!(:providers) { create_list(:individual, 2) }
  let(:provider) { providers.first }

  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/myfiles/file.pdf")) }

  describe '#create' do
    let(:params) do
      {
        provider: provider.attributes.merge(
          name: 'Custom provider 9991234999',
          document: '9991234999',

          attachments_attributes: {
            '0': { '_destroy': false, provider_id: provider.id, file: file }
          },

          provider_classifications_attributes: {
            '0': { '_destroy': false, classification_id: provider.classification_ids.first, file: file }
          }
        )
      }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    describe 'JSON' do
      context 'when created' do
        before { post_create }

        let(:saved_provider) { Provider.find_by(document: '9991234999') }

        it { expect(response).to have_http_status :created }
        it { expect(saved_provider.attachments.size).to eq 1 }
      end

      context 'when not created' do
        let(:json) { JSON.parse(response.body) }

        before do
          allow(controller.provider).to receive(:save) { false }
          allow(controller.provider).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end

    context 'with classifications' do
      let!(:provider) { create(:provider, :provider_classifications) }
      let(:params) do
        {
          provider: {
            document: '999999-12345',
            name: 'Provider 123',
            type: 'Individual',
            provider_classifications_attributes:{
              '0': { '_destroy': false, classification_id: provider.classifications[0].id },
              '1': { '_destroy': false, classification_id: provider.classifications[1].id },
              '2': { '_destroy': true, classification_id: provider.classifications[2].id }
            }
          }
        }
      end

      subject(:post_create) { post :create, params: params, xhr: true }

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        context 'when created' do
          before { post_create }

          let(:provider_saved) { Provider.find(json['provider']['id']) }

          it { expect(response).to have_http_status :created }
          it { expect(provider_saved.classifications.size).to eq 2 }
        end
      end
    end
  end

  describe '#update' do
    let(:new_name) { 'Updated Provider' }
    let(:params) { { id: provider.id, provider: { name: new_name } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    describe 'exposes' do
      before { post_update }

      it { expect(controller.provider.id).to eq provider.id }
      it { expect(controller.provider.name).to eq new_name }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.provider).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['provider']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.provider).to receive(:save) { false }
          allow(controller.provider).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end

    describe 'with classifications' do
      let!(:provider) { create(:provider, :provider_classifications) }
      let(:params) do
        {
          id: provider,
          provider: {
            document: provider.document,
            name: 'Provider 122',
            type: 'Individual',
            provider_classifications_attributes:{
              '0': { '_destroy': false, classification_id: provider.classifications[0].id },
              '1': { '_destroy': false, classification_id: provider.classifications[1].id },
              '2': { '_destroy': true, classification_id: provider.classifications[2].id }
            }
          }
        }
      end

      subject(:post_update) { patch :update, params: params, xhr: true }

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        context 'when created' do
          before { post_update }

          let(:provider_saved) { Provider.find(json['provider']['id']) }

          it { expect(response).to have_http_status :ok }
          it { expect(provider_saved.classifications.size).to eq 6 }
          it { expect(provider_saved.name).to_not eq provider.name }
        end
      end
    end
  end
end
