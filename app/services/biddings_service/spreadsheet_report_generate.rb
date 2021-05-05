module BiddingsService
  class SpreadsheetReportGenerate
    include TransactionMethods
    include Call::WithExceptionsMethods

    delegate :spreadsheet_report, to: :bidding

    def main_method
      generate_spreadsheet_report
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def generate_spreadsheet_report
      execute_or_rollback do
        if report.present?
          spreadsheet_report.present? ? update_spreadsheet_report! : update_bidding!
        end
      end
    end

    def update_spreadsheet_report!
      spreadsheet_report.update!(file: file)
    end

    def update_bidding!
      bidding.update!(spreadsheet_report: create_spreadsheet_report!)
    end

    def create_spreadsheet_report!
      SpreadsheetDocument.create!(file: file)
    end

    def file 
      @file ||= begin
        ReportsService::Biddings::Items::Download.call(report: report, bidding: bidding)
        File.open(report.url)
      end
    end

    def report
      @report ||= Report.create!(admin: bidding.admin, report_type: :bidding_items)
    end
  end
end
