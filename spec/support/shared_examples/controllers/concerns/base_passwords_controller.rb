def reset_password_token
  message = ActionMailer::Base.deliveries.last.body.raw_source
  rpt_index = message.index("reset_password_token")+"reset_password_token".length+1
  return message[rpt_index...message.index("\"", rpt_index)]
end

RSpec.shared_examples "a password operations to" do |user_type|
  let!(:user_type_sym) { user_type.to_sym }
  let!(:user_type_class) { user_type.capitalize.constantize }
  let!(:email_params) { { "#{user_type}": { email: resource.email } } }

  before do
    @request.env["devise.mapping"] = Devise.mappings[user_type_sym]

    ActionMailer::Base.deliveries = []
  end

  describe '#create' do
    before { post_create }

    subject(:post_create) { post :create, params: email_params, xhr: true }

    context 'when it finishes successfully' do
      describe 'email' do
        before do
          @email = ActionMailer::Base.deliveries.last
        end

        it { expect(@email.subject).to eq('Recuperação de senha') }

        describe 'the href domain' do
          let(:domain) do
            Rails.application.secrets.dig(:forgotten_password_path, user_type_sym)
          end

          before do
            body = @email.body.raw_source
            href_index = body.index("href")+"href".length+2
            @domain = body[href_index...body.index("/#", href_index)] + "/#"
          end

          it { expect(@domain).to eq(domain) }
        end
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        it { expect(json['success']).to be_truthy }
      end
    end

    context 'when there are errors' do
      context 'without email' do
        let(:email_params) { { "#{user_type}": { } } }

        describe 'email' do
          it { expect(ActionMailer::Base.deliveries).to be_empty }
        end

        describe 'JSON' do
          let(:json) { JSON.parse(response.body) }

          it { expect(json['errors'][user_type]).to eq('not_found') }
        end
      end

      context 'invalid email' do
        let(:email_params) { { "#{user_type}": { email: 'random@random.org' } } }

        describe 'email' do
          it { expect(ActionMailer::Base.deliveries).to be_empty }
        end

        describe 'JSON' do
          let(:json) { JSON.parse(response.body) }

          it { expect(json['errors'][user_type]).to eq('not_found') }
        end
      end
    end
  end

  describe '#update' do
    subject(:put_update) { put :update, params: params, xhr: true }

    before do
      allow(DateTime).to receive(:current) { DateTime.new(2018, 1, 1, 0, 0, 0) }
    end

    context 'when it finishes successfully' do
      let(:valid_password) { 'newpass123' }
      let(:params) do
        {
          "#{user_type}": {
            reset_password_token: @reset_password_token,
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      before do
        post :create, params: email_params, xhr: true
        oauth_token_sign_in resource
        oauth_token_sign_out resource
        @reset_password_token = reset_password_token
        put_update
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:resource_updated) { user_type_class.find(json[user_type_sym.to_s]['id']) }

        before { resource.reload }

        it { expect(response).to have_http_status :ok }
        it { expect(resource_updated.access_tokens.map(&:revoked_at)).to eq [DateTime.current] }
        it { expect(resource.valid_password?(valid_password)).to be_truthy }
      end
    end

    context 'when there are errors' do
      context 'and reset_password_token is valid' do
        before do
          post :create, params: email_params, xhr: true
          @reset_password_token = reset_password_token
          put_update
        end

        context 'and without password' do
          let(:valid_password) { 'newpass123' }
          let(:params) do
            {
              "#{user_type}": {
                reset_password_token: @reset_password_token,
                password_confirmation: valid_password
              }
            }
          end

          describe 'JSON' do
            let(:json) { JSON.parse(response.body) }

            it { expect(json['errors']['password']).to eq('missing') }
          end
        end

        context 'and password has invalid length' do
          let(:invalid_password) { 'np1' }
          let(:params) do
            {
              "#{user_type}": {
                reset_password_token: @reset_password_token,
                password: invalid_password,
                password_confirmation: invalid_password
              }
            }
          end

          describe 'JSON' do
            let(:json) { JSON.parse(response.body) }

            it { expect(json['errors']['password']).to eq('invalid') }
          end
        end

        context 'and password not equal to password_confirmation' do
          let(:valid_password) { 'newpass123' }
          let(:params) do
            {
              "#{user_type}": {
                reset_password_token: @reset_password_token,
                password: valid_password,
                password_confirmation: valid_password + 'test'
              }
            }
          end

          describe 'JSON' do
            let(:json) { JSON.parse(response.body) }

            it { expect(json['errors']['password_confirmation']).to eq('invalid') }
          end
        end
      end

      context 'and reset_password_token is invalid' do
        before { put_update }

        context 'and without reset_password_token' do
          let(:valid_password) { 'newpass123' }
          let(:params) do
            {
              "#{user_type}": {
                password: valid_password,
                password_confirmation: valid_password
              }
            }
          end

          describe 'JSON' do
            let(:json) { JSON.parse(response.body) }

            it { expect(json['errors']['reset_password_token']).to eq('missing') }
          end
        end

        context 'and invalid reset_password_token' do
          let(:valid_password) { 'newpass123' }
          let(:params) do
            {
              "#{user_type}": {
                reset_password_token: 'invalid',
                password: valid_password,
                password_confirmation: valid_password
              }
            }
          end

          describe 'JSON' do
            let(:json) { JSON.parse(response.body) }

            it { expect(json['errors']['reset_password_token']).to eq('invalid') }
          end
        end
      end
    end
  end
end
