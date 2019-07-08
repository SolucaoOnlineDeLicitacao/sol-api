class Bidding::LotProposalImportFileGenerateWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(bidding_id, lot_id)
    BiddingsService::LotProposalImports::Download.call(bidding_id: bidding_id, lot_id: lot_id)
  end
end
