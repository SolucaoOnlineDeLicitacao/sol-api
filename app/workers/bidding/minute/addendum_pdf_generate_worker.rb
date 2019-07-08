class Bidding::Minute::AddendumPdfGenerateWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(contract_id)
    # unscoped because at this point the contract may be marked as deleted
    contract = Contract.unscoped.find(contract_id)
    BiddingsService::Minute::AddendumPdfGenerate.call!(contract: contract)
  end
end
