require 'rails_helper'

RSpec.describe Coop::DeviceTokensController, type: :controller do
  let(:user) { create :user }

  describe 'BaseDeviceTokensController' do
    include_examples 'controllers/concerns/base_device_tokens_controller'
  end
end
