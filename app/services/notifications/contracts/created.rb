module Notifications
  class Contracts::Created < Contracts::Base

    private

    def body_args
      [contract.title]
    end

    def receivables
      [admin, suppliers]
    end
  end
end
