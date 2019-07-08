module EventServices::Provider
  class Unblock < Base
    BLOCKED = 0

    private

    def blocked
      BLOCKED
    end
  end
end
