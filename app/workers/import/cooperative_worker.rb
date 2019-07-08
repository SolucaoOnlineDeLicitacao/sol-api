class Import::CooperativeWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    Integration::Cooperative::Import.call
  end
end
