module Notifications::Contracts
  class Refused
    include TransactionMethods
    include Call::Methods

    def main_method
      notify_resources
    end

    private

    def notify_resources
      execute_or_rollback do
        return notify_all if contract.refused_by_type_system?

        Notifications::Contracts::Refused::User.call(contract: contract)

        notify_admin_and_user if contract.refused_by_type_supplier?
      end
    end

    def notify_all
      Notifications::Contracts::Refused::All.call(contract: contract)
    end

    def notify_admin_and_user
      Notifications::Contracts::Refused::Supplier.call(contract: contract)
    end
  end
end
