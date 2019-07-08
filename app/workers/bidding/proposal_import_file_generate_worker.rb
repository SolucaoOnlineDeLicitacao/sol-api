class Bidding::ProposalImportFileGenerateWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(bidding_id)
    BiddingsService::ProposalImports::Download.call(bidding_id: bidding_id)
  end
end
