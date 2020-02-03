module TransactionMethods
  EXCEPTIONS = [
    ActiveRecord::RecordInvalid,
    ActiveRecord::RecordNotDestroyed,
    ActiveRecord::RecordNotUnique,
    BlockchainError,
    RecalculateItemError,
    ArgumentError,
    CreateContractError
  ].freeze

  def execute_or_rollback(&block)
    ActiveRecord::Base.transaction do
      block.call
      return true
    rescue *EXCEPTIONS => error
      Rails.logger.error error.message
      Rails.logger.error error.backtrace
      raise ActiveRecord::Rollback
      return false
    end
  end
end
