class AdditiveService
  include TransactionMethods
  include Call::Methods

  delegate :bidding, to: :additive

  def main_method
    execute_and_perform
  end

  private

  def execute_and_perform
    regenerate_pdf_edict if bidding_additive
    bidding_additive
  end

  def bidding_additive
    @bidding_additive ||= begin
      execute_or_rollback do
        updates_additive_from!
        save_and_update_bidding!
        notify
      end
    end
  end

  def updates_additive_from!
    additive.from = bidding.closing_date
  end

  def save_and_update_bidding!
    additive.save!
    bidding.update!(closing_date: additive.to)
  end

  def regenerate_pdf_edict
    Bidding::EdictPdfGenerateWorker.perform_async(bidding.id)
  end

  def notify
    Notifications::Biddings::Additives::Created.call(bidding)
  end
end
