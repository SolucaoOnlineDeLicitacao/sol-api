class CoopController < ApplicationController
  before_action -> { doorkeeper_authorize! :user }

  def current_cooperative
    return nil unless current_user
    @current_cooperative ||= current_user.cooperative
  end
end
