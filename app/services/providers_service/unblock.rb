module ProvidersService
  class Unblock < Base
    private

    def blocked
      false
    end

    def service
      EventServices::Provider::Unblock
    end
  end
end
