module ContractsService
  class SystemRefuse
    include TransactionMethods
    include Call::WithExceptionsMethods

    COMMENT_REFUSED_SYSTEM = I18n.t(
      'services.contracts.system_refuse.comment'
    ).freeze

    def main_method
      system_refuse
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def system_refuse
      execute_or_rollback do
        Contract.waiting_signature_and_old.each do |contract|
          ContractsService::Refused.
            call!(contract: contract, refused_by: system, comment: COMMENT_REFUSED_SYSTEM)
        end
      end
    end

    def system
      @system ||= System.last
    end
  end
end
