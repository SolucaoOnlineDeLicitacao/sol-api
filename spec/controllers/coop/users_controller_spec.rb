require 'rails_helper'

RSpec.describe Coop::UsersController, type: :controller do
  let(:user) { create :user }

  before { oauth_token_sign_in user }

  describe '#profile' do
    let(:params) do
      {
        user: { password: 'test1234', password_confirmation: 'test1234' }
      }
    end

    subject(:patch_profile) do
      patch :profile, params: params, xhr: true
    end

    it_behaves_like 'an user authorization to', 'write'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:avatar) do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/myfiles/avatar.png")
        )
      end

      let(:user_json) do
        {
          'id'       => user.id,
          'name'     => user.name,
          'username' => user.email,
        }
      end

      before do 
        allow(DateTime).to receive(:current) { DateTime.new(2018, 1, 1, 0, 0, 0) }
      end

      context 'when updating only password' do
        
        before { patch_profile } 

        context 'when is a valid password' do
          let(:user_updated) { User.find(json['user']['id']) } 

          it { expect(response).to have_http_status :ok }
          it { expect(json['user']).to include user_json }
          it { expect(user_updated.access_tokens.map(&:revoked_at)).to eq [DateTime.current] }
        end

        context 'when is a invalid password' do
          let(:params) do
            {
              user: { password: 'test1234',  password_confirmation: 'test12345' }
            }
          end

          it { expect(response).to have_http_status :unprocessable_entity }
          it { expect(json['errors']).to be_present }
        end
      end

      context 'when updating only avatar' do
        let(:params) do
          {
            user: { avatar: avatar, password: '', password_confirmation: '' }
          }
        end

        before { patch_profile } 

        it { expect(response).to have_http_status :ok }
        it { expect(json['user']).to include user_json }
        it { expect(json['user']['avatar']['url']).to include('avatar.png') }
      end

      context 'when updating password and avatar' do
        let(:user_updated) { User.find(json['user']['id']) } 
        let(:params) do
          {
            user: {
              password: 'test1234',  password_confirmation: 'test1234',
              avatar: avatar
            }
          }
        end

        before { patch_profile } 

        it { expect(response).to have_http_status :ok }
        it { expect(json['user']).to include user_json }
        it { expect(json['user']['avatar']['url']).to include('avatar.png') }
        it { expect(user_updated.access_tokens.map(&:revoked_at)).to eq [DateTime.current] }
      end

      context 'when is a invalid update token' do
        before do
          allow_any_instance_of(described_class).to receive(:update_access_token!).and_raise(ActiveRecord::RecordInvalid)
          patch_profile
        end

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
