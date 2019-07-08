class Import::ItemWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    Integration::Item::Import.call
  end
end
