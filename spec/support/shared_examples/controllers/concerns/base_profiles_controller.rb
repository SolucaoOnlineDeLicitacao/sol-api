RSpec.shared_examples "controllers/concerns/base_profiles_controller" do |key|
  before { oauth_token_sign_in resource }

  describe '#profile' do
    let(:json) { JSON.parse(response.body) }

    let(:params) do
      {
        "#{key}": { password: 'test1234', password_confirmation: 'test1234', locale: 'en-US', avatar: avatar }
      }
    end

    let(:avatar) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/avatar.png")
      )
    end

    let(:user_json) do
      {
        'id'       => resource.id,
        'name'     => resource.name,
        'username' => resource.email,
        'locale'   => resource.locale
      }
    end

    describe 'when success' do
      before do
        allow(DateTime).to receive(:current) { DateTime.new(2018, 1, 1, 0, 0, 0) }

        user_json['locale'] = 'es-PY'
        params[key][:locale] = 'es-PY'

        patch :profile, params: params, xhr: true

        resource.reload
      end

      it { expect(response).to have_http_status :ok }
      it { expect(resource.locale).to eq 'es-PY' }
      it { expect(resource.access_tokens.map(&:revoked_at)).to eq [DateTime.current] }
      it { expect(json[key.to_s]).to include user_json }
    end

    describe 'when failure' do
      before { patch :profile, params: params, xhr: true }

      let!(:params) do
        {
          "#{key}": { avatar: nil, password: '',  password_confirmation: 'test12345' }
        }
      end

      it { expect(response).to have_http_status :unprocessable_entity }
      it { expect(json['errors']).to be_present }
    end
  end

end
