require 'rails_helper'

RSpec.describe Coop::NotificationsController, type: :controller do
  describe 'BaseNotificationsController' do
    include_examples 'controllers/concerns/base_notifications_controller' do
      let(:user) { create(:user) }
    end

    describe 'load_and_authorize_resource' do
      context 'when calling index method' do
        let(:user) { create(:user) }
        let(:params) { {} }

        subject(:get_index) { get :index, params: params, xhr: true }

        it_behaves_like 'an user authorization to', 'read'
        it_behaves_like 'a scope to' do
          let(:resource) { Notification }
        end
      end

      context 'when calling mark_as_read method' do
        let(:params) { { id: notification } }

        subject(:patch_mark_as_read) { patch :mark_as_read, params: params, xhr: true }

        it_behaves_like 'an user authorization to', 'read'
      end
    end
  end
end
