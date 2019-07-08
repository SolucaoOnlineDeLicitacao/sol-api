class Contract::SystemRefuseWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    ContractsService::SystemRefuse.call!
  end
end
