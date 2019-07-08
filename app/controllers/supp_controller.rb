class SuppController < ApplicationController
  before_action -> { doorkeeper_authorize! :supplier }

  def current_provider
    return nil unless current_user
    @current_provider ||= current_user.provider
  end
end
