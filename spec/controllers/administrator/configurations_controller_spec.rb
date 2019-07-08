require 'rails_helper'

RSpec.describe Administrator::ConfigurationsController, type: :controller do
  let(:serializer) { Administrator::ConfigurationSerializer }
  let(:admin_user) { create :admin }
  let!(:configurations) { [create(:integration_cooperative_configuration)] }
  let(:configuration) { configurations.first }

  before { oauth_token_sign_in admin_user }

  describe '#import' do
    let(:params) { { id: configuration } }

    subject(:post_import) { post :import, params: params, xhr: true }

    describe 'response' do
      before do
        post_import
        configuration.reload
      end

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.configuration).to eq configuration }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        it { expect(json['status']).to eq configuration.status }
      end
    end
  end

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.configurations).to eq configurations }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { configurations.map { |conf| format_json(serializer, conf) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#update' do
    let(:new_token) { 'n3ws3cr3t' }
    let(:params) { { id: configuration, configuration: { token: new_token } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    describe 'exposes' do
      before { post_update }

      it { expect(controller.configuration.id).to eq configuration.id }
      it { expect(controller.configuration.token).to eq new_token }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.configuration).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['configuration']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.configuration).to receive(:save) { false }
          allow(controller.configuration).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

end
