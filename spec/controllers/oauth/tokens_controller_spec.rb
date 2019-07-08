require 'rails_helper'

RSpec.describe Doorkeeper::TokensController, type: :controller do

  context "for users - scope: 'user'" do
    let!(:app) { create :oauth_application, scopes: 'user' }

# XXX: disabled. It needs some thinking on what scopes to return. Probably :public
# @see comments on initializers/doorkeeper.rb about client credentials and Doorkeeper::OAuth::ClientCredentialsRequest
#
#    describe 'client credentials' do
#      let(:grant_type) { 'client_credentials' }
#      let(:params) { { grant_type: grant_type } }
#
#      subject(:post_create) { post :create, params: params, xhr: true }
#
#      context 'using headers' do
#        context 'with valid client credentials' do
#          before do # headers
#            credentials = Base64.strict_encode64("#{app.uid}:#{app.secret}")
#            request.headers.merge! 'Authorization' => "Basic #{credentials}"
#          end
#
#          it 'creates an access token' do
#            expect { post_create }.to change { app.access_tokens.count }.by(1)
#            data = JSON.parse response.body
#
#            expect(data['token_type']).to eq 'bearer'
#            expect(data['scope']).to eq app.scopes.to_s
#            expect(data['access_token']).to be_present
#          end
#        end
#
#        context 'with invalid client credentials' do
#          before do # headers
#            credentials = Base64.strict_encode64("#{app.uid}:invalid-secret")
#            request.headers.merge! 'Authorization' => "Basic #{credentials}"
#          end
#
#          it 'does not create am access token' do
#            expect { post_create }.not_to change { app.access_tokens.count }
#
#            data = JSON.parse response.body
#
#            expect(data['error']).to eq 'invalid_client'
#          end
#        end
#      end
#
#      context 'using params' do
#        before do # params
#          params.merge! client_id: app.uid, client_secret: app.secret
#        end
#
#        it 'creates an access token' do
#          expect { post_create }.to change { app.access_tokens.count }.by(1)
#
#          data = JSON.parse response.body
#
#          expect(data['token_type']).to eq 'bearer'
#          expect(data['scope']).to eq app.scopes.to_s
#          expect(data['access_token']).to be_present
#        end
#      end
#
#    end

    describe 'resource owner password credentials' do
      let!(:user) { create :user, password: 's3cr3t', password_confirmation: 's3cr3t' }
      let(:grant_type) { 'password' }
      let(:params) do
        {
          grant_type: grant_type,
          username: user.email,
          password: 's3cr3t'
        }
      end

      subject(:post_create) { post :create, params: params, xhr: true }

      before do # headers
        credentials = Base64.strict_encode64("#{app.uid}:#{app.secret}")
        request.headers.merge! 'Authorization' => "Basic #{credentials}"
      end

      context 'requirements' do
        it 'requires client credentials' do
          request.headers.merge! 'Authorization' => "blank-or-invalid"

          post_create

          expect(response).to have_http_status :unauthorized

          data = JSON.parse response.body
          expect(data['error']).to eq 'invalid_client'
        end
      end

      context 'with invalid resource owner password credentials' do
        before { params.merge! password: 'invalid-passwd' }

        it 'does not create an access token' do
          expect { post_create }.not_to change { user.access_tokens.count }

          data = JSON.parse response.body
          expect(data['error']).to eq 'invalid_grant'
        end
      end


      context 'with valid resource owner password credentials' do
        it 'creates an access token' do
          expect { post_create }.to change { user.access_tokens.count }.by(1)

          data = JSON.parse response.body
          expect(data['token_type']).to eq 'bearer'
          expect(data['scope']).to eq app.scopes.to_s
          expect(data['access_token']).to be_present

          # custom data, made on initializers/doorkeeper.rb
          # expect(data['user']).to eq({
          expect(data['user']).to include({
            'id'       => user.id,
            'name'     => user.name,
            'username' => user.email
          })
        end

        it 'ignores custom :scope param, enforcing client/application pre-defined scope' do
          params.merge! scope: 'customtest'

          expect { post_create }.to change { user.access_tokens.count }.by(1)

          data = JSON.parse response.body
          expect(data['token_type']).to eq 'bearer'
          expect(data['scope']).to eq app.scopes.to_s
          expect(data['access_token']).to be_present
        end
      end

      context 'with valid admin credentials, but invalid since we need user' do
        let!(:admin) { create :admin, password: 'admin-passwd', password_confirmation: 'admin-passwd' }
        before { params.merge! username: admin.email, password: 'admin-passwd' }

        it 'does not create an access token' do
          expect { post_create }.not_to change { user.access_tokens.count }

          data = JSON.parse response.body
          expect(data['error']).to eq 'invalid_grant'
        end
      end

    end
  end # for users



  # ----


  context "for admins - scope: 'admin'" do
    let!(:app) { create :oauth_application, scopes: 'admin' }

# XXX: disabled. It needs some thinking on what scopes to return. Probably :public
# @see comments on initializers/doorkeeper.rb about client credentials and Doorkeeper::OAuth::ClientCredentialsRequest
#
#    describe 'client credentials' do
#      let(:grant_type) { 'client_credentials' }
#      let(:params) { { grant_type: grant_type } }
#
#      subject(:post_create) { post :create, params: params, xhr: true }
#
#      context 'using headers' do
#        context 'with valid client credentials' do
#          before do # headers
#            credentials = Base64.strict_encode64("#{app.uid}:#{app.secret}")
#            request.headers.merge! 'Authorization' => "Basic #{credentials}"
#          end
#
#          it 'creates an access token' do
#            expect { post_create }.to change { app.access_tokens.count }.by(1)
#            data = JSON.parse response.body
#
#            expect(data['token_type']).to eq 'bearer'
#            expect(data['scope']).to eq app.scopes.to_s
#            expect(data['access_token']).to be_present
#          end
#        end
#
#        context 'with invalid client credentials' do
#          before do # headers
#            credentials = Base64.strict_encode64("#{app.uid}:invalid-secret")
#            request.headers.merge! 'Authorization' => "Basic #{credentials}"
#          end
#
#          it 'does not create am access token' do
#            expect { post_create }.not_to change { app.access_tokens.count }
#
#            data = JSON.parse response.body
#
#            expect(data['error']).to eq 'invalid_client'
#          end
#        end
#      end
#
#      context 'using params' do
#        before do # params
#          params.merge! client_id: app.uid, client_secret: app.secret
#        end
#
#        it 'creates an access token' do
#          expect { post_create }.to change { app.access_tokens.count }.by(1)
#
#          data = JSON.parse response.body
#
#          expect(data['token_type']).to eq 'bearer'
#          expect(data['scope']).to eq app.scopes.to_s
#          expect(data['access_token']).to be_present
#        end
#      end
#
#    end


    describe 'resource owner password credentials' do
      let!(:admin) { create :admin, password: 's3cr3t', password_confirmation: 's3cr3t' }
      let(:grant_type) { 'password' }
      let(:params) do
        {
          grant_type: grant_type,
          username: admin.email,
          password: 's3cr3t'
        }
      end
      subject(:post_create) { post :create, params: params, xhr: true }

      before do # headers
        credentials = Base64.strict_encode64("#{app.uid}:#{app.secret}")
        request.headers.merge! 'Authorization' => "Basic #{credentials}"
      end

      context 'requirements' do
        it 'requires client credentials' do
          request.headers.merge! 'Authorization' => "blank-or-invalid"

          post_create

          expect(response).to have_http_status :unauthorized

          data = JSON.parse response.body
          expect(data['error']).to eq 'invalid_client'
        end
      end

      context 'with invalid resource owner password credentials' do
        before { params.merge! password: 'invalid-passwd' }

        it 'does not create an access token' do
          expect { post_create }.not_to change { admin.access_tokens.count }

          data = JSON.parse response.body
          expect(data['error']).to eq 'invalid_grant'
        end
      end


      context 'with valid resource owner password credentials' do
        it 'creates an access token' do
          expect { post_create }.to change { admin.access_tokens.count }.by(1)

          data = JSON.parse response.body
          expect(data['token_type']).to eq 'bearer'
          expect(data['scope']).to eq app.scopes.to_s
          expect(data['access_token']).to be_present

          # custom data, made on initializers/doorkeeper.rb
          # expect(data['user']).to eq({
          expect(data['user']).to include({
            'id'       => admin.id,
            'name'     => admin.name,
            'username' => admin.email
          })
        end

        it 'ignores custom :scope param, enforcing client/application pre-defined scope' do
          params.merge! scope: 'customtest'

          expect { post_create }.to change { admin.access_tokens.count }.by(1)

          data = JSON.parse response.body
          expect(data['token_type']).to eq 'bearer'
          expect(data['scope']).to eq app.scopes.to_s
          expect(data['access_token']).to be_present
        end
      end


      context 'with valid user credentials, but invalid since we need admin' do
        let!(:user) { create :user, password: 'user-passwd', password_confirmation: 'user-passwd' }
        before { params.merge! username: user.email, password: 'user-passwd' }

        it 'does not create an access token' do
          expect { post_create }.not_to change { admin.access_tokens.count }

          data = JSON.parse response.body
          expect(data['error']).to eq 'invalid_grant'
        end
      end

    end
  end # for admins


  # oauth_revoke POST   /oauth/revoke(.:format)   doorkeeper/tokens#revoke
  context '#revoke' do
    let!(:user) { create :user, password: 's3cr3t', password_confirmation: 's3cr3t' }
    let!(:token) { oauth_token_sign_in user, app: app }

    let(:params) { { token: token.token } }
    subject(:post_revoke) { post :revoke, params: params, xhr: true }

    # @see https://tools.ietf.org/html/rfc6749#section-2.1 for the difference between confidential
    # and public clients

    context 'with a confidential client (server side app)' do
      let(:app) { create :oauth_application, scopes: 'user', confidential: true }

      it 'requires client credentials' do
        params.delete %i[client_id client_secret].sample

        expect { post_revoke }.not_to change { user.access_tokens.where.not(revoked_at: nil).count }
      end

      it 'revokes the token (using client credentials)' do
        params.merge! client_id: app.uid, client_secret: app.secret

        expect { post_revoke }.to change { user.access_tokens.where.not(revoked_at: nil).count }.by(1)
      end
    end

    context 'with a public (non-confidential) client (webapp, mobile native app)' do
      let(:app) { create :oauth_application, scopes: 'user', confidential: false }

      it 'revokes the token' do
        expect { post_revoke }.to change { user.access_tokens.where.not(revoked_at: nil).count }.by(1)
      end
    end

  end
end
