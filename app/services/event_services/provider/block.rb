module EventServices::Provider
  class Block < Base
    BLOCKED = 1

    private

    def blocked
      BLOCKED
    end
  end
end
