module ReportsService
  class Create
    include TransactionMethods
    include Call::WithAsyncMethods

    attr_accessor :report

    REPORTS = {
      'biddings' => Reports::BiddingsWorker,
      'contracts' => Reports::ContractsWorker,
      'time' => Reports::TimeWorker,
      'items' => Reports::ItemsWorker,
      'suppliers_biddings' => Reports::SuppliersBiddingsWorker,
      'suppliers_contracts' => Reports::SuppliersContractsWorker
    }.freeze

    def main_method
      create_report
    end

    def async_method
      report_worker.perform_async(report.id)
    end

    private

    def create_report
      execute_or_rollback do
        @report = Report.create!(admin: admin, report_type: report_type.try(:to_sym))
      end
    end

    def report_worker
      REPORTS[report_type]
    end
  end
end
