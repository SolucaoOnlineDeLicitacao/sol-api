require 'rails_helper'

RSpec.describe Administrator::NotificationsController, type: :controller do
  describe 'BaseNotificationsController' do
    let(:admin) { create(:admin) }

    include_examples 'controllers/concerns/base_notifications_controller' do
      let(:user) { admin }
    end

    describe 'load_and_authorize_resource' do
      context 'when calling index method' do
        let(:params) { {} }

        subject(:get_index) { get :index, params: params, xhr: true }

        it_behaves_like 'an admin authorization to', 'admin', 'read'
        it_behaves_like 'a scope to' do
          let(:resource) { Notification }
        end
      end

      context 'when calling mark_as_read method' do
        let(:params) { { id: notification } }

        subject(:patch_mark_as_read) { patch :mark_as_read, params: params, xhr: true }

        it_behaves_like 'an admin authorization to', 'admin', 'read'
      end
    end
  end
end
