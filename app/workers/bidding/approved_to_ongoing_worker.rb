class Bidding::ApprovedToOngoingWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5
  
  def perform
    BiddingsService::ApprovedToOngoing.call
  end
end
