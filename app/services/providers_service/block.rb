module ProvidersService
  class Block < Base
    private

    def blocked
      true
    end

    def service
      EventServices::Provider::Block
    end
  end
end
