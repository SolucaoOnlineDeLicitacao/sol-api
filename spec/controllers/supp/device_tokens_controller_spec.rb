require 'rails_helper'

RSpec.describe Supp::DeviceTokensController, type: :controller do
  let(:user) { create :supplier }

  describe 'BaseDeviceTokensController' do
    include_examples 'controllers/concerns/base_device_tokens_controller'
  end
end
