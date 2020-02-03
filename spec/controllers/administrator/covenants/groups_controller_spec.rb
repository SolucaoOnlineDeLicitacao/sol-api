require 'rails_helper'

RSpec.describe Administrator::Covenants::GroupsController, type: :controller do
  let(:serializer) { Administrator::GroupSerializer }
  let(:user) { create :admin }
  let(:covenant) { create(:covenant) }

  before { oauth_token_sign_in user }

  describe '#show' do
    let!(:group) { create(:group, covenant: covenant) }

    let(:params) { { covenant_id: group.covenant, id: group } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.group).to eq group }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, group) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:group) { build(:group, covenant: covenant) }
    let(:group_item) { build(:group_item, group: group) }
    let(:params) do
      {
        group: group.attributes.merge(group_items_attributes: [group_item.attributes]),
        covenant_id: group.covenant
      }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_create', 'group'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.group).to be_instance_of Group }
      it { expect(controller.group.covenant).to eq covenant }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.group).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['group']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.group).to receive(:save) { false }
          allow(controller.group).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let!(:group) { create(:group, covenant: covenant) }
    let(:new_name) { 'Updated Group2' }
    let(:group_item) { build(:group_item, group: group) }

    let(:params) do
      {
        covenant_id: group.covenant, id: group,  group: {
          name: new_name, group_items_attributes: [group_item.attributes]
        }
      }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_update', 'group'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.group.id).to eq group.id }
      it { expect(controller.group.name).to eq new_name }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.group).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['group']).to be_present }
      end

      context 'when not updated' do
        let(:group_item) { build(:group_item, group: group, quantity: nil) }
        before do
          allow(controller.group).to receive(:errors_as_json) { { error: 'value' } }
          post_update
        end

        it { expect(json.dig('errors', 'error')).to eq 'value' }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let!(:group) { create(:group, covenant: covenant) }
    let(:params) { { covenant_id: covenant, id: group } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'delete_destroy', 'group'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.group).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.group).to receive(:destroy) { false }
          allow(controller.group).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
