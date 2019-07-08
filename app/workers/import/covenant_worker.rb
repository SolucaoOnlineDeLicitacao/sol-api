class Import::CovenantWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    Integration::Covenant::Import.call
  end
end
