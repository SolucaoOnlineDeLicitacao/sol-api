class Bidding::DrawToUnderReviewWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    BiddingsService::DrawToUnderReview.call
  end
end
