module Search
  class UsersController < Search::BaseController

    private

    def base_resources
      User
    end
  end
end
