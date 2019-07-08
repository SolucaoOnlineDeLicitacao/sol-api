module Notifications
  class Contracts::Sign::AdminUser < Contracts::Base

    private

    def receivables
      [admin, user]
    end

    def body_args
      [contract.title, bidding.title, supplier.name]
    end

    def admin
      @admin ||= bidding.admin
    end
  end
end
