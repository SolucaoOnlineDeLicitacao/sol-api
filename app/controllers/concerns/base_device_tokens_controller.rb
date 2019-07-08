module BaseDeviceTokensController
  extend ActiveSupport::Concern

  included do
    expose :device_tokens, -> { find_device_tokens }
    expose :device_token
  end

  def create
    self.device_token = find_or_create_device_token if device_token_param

    render :ok
  end

  private

  def resources
    device_tokens
  end

  def find_or_create_device_token
    current_user.device_tokens.find_or_create_by(body: device_token_param)
  end

  def find_device_tokens
    current_user.device_tokens
  end

  def device_token_param
    params.fetch(:body, '')
  end
end
