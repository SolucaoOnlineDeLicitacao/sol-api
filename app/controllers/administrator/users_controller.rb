module Administrator
  class UsersController < AdminController
    include CrudController

    load_and_authorize_resource

    before_action :set_paper_trail_whodunnit
    before_action :skip_password_validation, on: :create

    PERMITTED_PARAMS = [
      :id, :name, :email, :cpf, :phone, :cooperative_id, :role_id
    ].freeze

    expose :users, -> { find_users }
    expose :user

    private

    def skip_password_validation
      user.skip_password_validation!
    end

    def resource
      user
    end

    def resources
      users
    end

    def find_users
      User.accessible_by(current_ability)
    end

    def user_params
      params.require(:user).permit(*PERMITTED_PARAMS)
    end
  end
end
