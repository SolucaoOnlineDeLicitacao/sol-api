require 'rails_helper'

RSpec.describe Administrator::AdminsController, type: :controller do
  let(:serializer) { AdminSerializer }

  before { oauth_token_sign_in user }

  describe '#index' do
    let!(:users) { create_list(:admin, 2) }
    let(:user) { users.first }
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read himself'
    it_behaves_like 'a scope to' do
      let(:resource) { Admin }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_admins) { Admin.all }

      before do
        allow(exposed_admins).to receive(:search) { exposed_admins }
        allow(exposed_admins).to receive(:sorted) { exposed_admins }
        allow(exposed_admins).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:admins) { exposed_admins }

        get_index
      end

      it { expect(exposed_admins).to have_received(:search).with('search') }
      it { expect(exposed_admins).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_admins).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.admins).to eq users }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { users.map { |user| format_json(serializer, user) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let!(:user) { create(:admin) }
    let(:params) { { id: user } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read himself'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.admin).to eq user }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, user) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let!(:user) { create(:admin) }
    let(:another_user) { build(:admin) }
    let(:params) { { admin: another_user.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write himself'

    it_behaves_like 'a version of', 'post_create', 'admin'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.admin).to be_instance_of Admin }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.admin).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['admin']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.admin).to receive(:save) { false }
          allow(controller.admin).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let!(:user) { create(:admin) }
    let(:new_email) { 'caiena@caiena.net' }
    let(:params) { { id: user, admin: { email: new_email } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write himself'

    it_behaves_like 'a version of', 'post_update', 'admin'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.admin.id).to eq user.id }
      it { expect(controller.admin.email).to eq new_email }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.admin).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['admin']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.admin).to receive(:save) { false }
          allow(controller.admin).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let!(:user) { create(:admin) }
    let(:params) { { id: user } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete himself'

    it_behaves_like 'a version of', 'delete_destroy', 'admin'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.admin).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.admin).to receive(:destroy) { false }
          allow(controller.admin).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#profile' do
    let(:locale) { 'es-PY' }
    let(:user) { create :admin, locale: 'pt-BR' }
    let(:json) { JSON.parse(response.body) }

    let(:params) do
      {
        admin: { password: 'test1234', password_confirmation: 'test1234', locale: locale }
      }
    end

    let(:user_json) do
      {
        'id'       => user.id,
        'name'     => user.name,
        'username' => user.email,
        'locale'   => user.locale,
        'role'     => user.role,
        'rules'    => Abilities::Strategy.call(user: user).as_json
      }
    end

    before { oauth_token_sign_in user }

    describe 'when success' do
      before do
        allow(DateTime).to receive(:current) { DateTime.new(2018, 1, 1, 0, 0, 0) }
        patch :profile, params: params, xhr: true

        user.reload
      end

      it { expect(response).to have_http_status :ok }
      it { expect(user.locale).to eq locale }
      it { expect(user.access_tokens.map(&:revoked_at)).to eq [DateTime.current, DateTime.current] }
      it { expect(json['admin'].deep_symbolize_keys).to include user_json.deep_symbolize_keys }
    end

    describe 'when failure' do
      before { patch :profile, params: params, xhr: true }

      let!(:params) do
        {
          admin: { password: '',  password_confirmation: 'test12345' }
        }
      end

      it { expect(response).to have_http_status :unprocessable_entity }
      it { expect(json['errors']).to be_present }
    end

    describe "authorization" do
      it_behaves_like 'an admin authorization to', 'user', 'write himself'
    end
  end
end
