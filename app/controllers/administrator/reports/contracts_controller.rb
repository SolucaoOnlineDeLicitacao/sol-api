module Administrator
  class Reports::ContractsController < AdminController
    def index
      render json: ReportsService::Contract.call
    end
  end
end
