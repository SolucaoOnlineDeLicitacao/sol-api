class Reports::TimeWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform(report_id)
    report = Report.find(report_id)
    ReportsService::Biddings::TimeDays::Download.call(report: report)
  end
end
