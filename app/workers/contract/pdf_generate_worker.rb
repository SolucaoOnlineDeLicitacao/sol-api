class Contract::PdfGenerateWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(contract_id)
    contract = Contract.find(contract_id)
    ContractsService::PdfGenerate.call!(contract: contract)
  end
end
