class Bidding::OngoingToUnderReviewWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5
  
  def perform
    BiddingsService::OngoingToUnderReview.call
  end
end
