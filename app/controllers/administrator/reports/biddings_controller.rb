module Administrator
  class Reports::BiddingsController < AdminController
    def index
      render json: ReportsService::Bidding.call
    end
  end
end
