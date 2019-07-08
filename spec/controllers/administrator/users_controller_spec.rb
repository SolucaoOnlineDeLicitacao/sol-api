require 'rails_helper'

RSpec.describe Administrator::UsersController, type: :controller do
  let(:serializer) { UserSerializer }
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#index' do
    let!(:coop_users) { create_list(:user, 2) }
    let(:coop_user) { coop_users.first }
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { User }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_users) { User.all }

      before do
        allow(exposed_users).to receive(:search) { exposed_users }
        allow(exposed_users).to receive(:sorted) { exposed_users }
        allow(exposed_users).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:users) { exposed_users }

        get_index
      end

      it { expect(exposed_users).to have_received(:search).with('search') }
      it { expect(exposed_users).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_users).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.users).to match_array coop_users }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { coop_users.map { |coop_user| format_json(serializer, coop_user) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let!(:coop_user) { create(:user) }
    let(:params) { { id: coop_user } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.user).to eq coop_user }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, coop_user) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:coop_user) { build(:user) }
    let(:params) { { user: coop_user.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_create', 'user'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.user).to be_instance_of User }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.user).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['user']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.user).to receive(:save) { false }
          allow(controller.user).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let!(:coop_user) { create(:user) }
    let(:new_email) { 'caiena@caiena.net' }
    let(:params) { { id: coop_user, user: { email: new_email } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'user'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.user.id).to eq coop_user.id }
      it { expect(controller.user.email).to eq new_email }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.user).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['user']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.user).to receive(:save) { false }
          allow(controller.user).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let!(:coop_user) { create(:user) }
    let(:params) { { id: coop_user } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'user'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.user).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.user).to receive(:destroy) { false }
          allow(controller.user).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
