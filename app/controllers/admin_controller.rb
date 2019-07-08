class AdminController < ApplicationController
  before_action -> { doorkeeper_authorize! :admin }
end
