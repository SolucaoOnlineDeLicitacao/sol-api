class Reports::ItemsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(report_id)
    report = Report.find(report_id)
    ReportsService::Items::Prices::Download.call(report: report)
  end
end
