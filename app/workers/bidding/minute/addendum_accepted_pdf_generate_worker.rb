class Bidding::Minute::AddendumAcceptedPdfGenerateWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(bidding_id)
    bidding = Bidding.find(bidding_id)

    # unscoped because at this point the contract may be marked as deleted
    reopen_reason_contract = ::Contract.unscoped.find(bidding.reopen_reason_contract_id)

    # TODO: when bidding generate 2 contracts or more, what happens here
    #       with bidding.reopen_reason_contract? (think about the new flow)
    # suggestion: at ContractsService::Proposals::Base we can store
    #             an array of contracts for example instead of one contract,
    #             and after that we can add 2 addendums or more, 1 per contract
    BiddingsService::Minute::AddendumAcceptedPdfGenerate.call!(contract: reopen_reason_contract)
  end
end
