RSpec.shared_examples "controllers/concerns/base_device_tokens_controller" do
  let!(:device_token) { create(:device_token, owner: user) }

  before { oauth_token_sign_in user }

  describe '#create' do
    let(:params) { { body: device_token.body } }

    subject(:post_create) { post :create, params: params, xhr: true }

    describe 'render' do
      before { post_create }

      it { expect(response).to be_ok }
    end

    describe 'exposes' do
      subject { controller.device_token }

      context 'when new token' do
        let(:token_body) { 'newToken' }
        let!(:params) { { body: token_body } }

        before { post_create }

        it { expect(subject.body).to eq token_body }
        it { is_expected.to be_a DeviceToken }
      end

      context 'when existing token' do
        before { post_create }

        it { is_expected.to eq device_token }
      end
    end
  end
end
