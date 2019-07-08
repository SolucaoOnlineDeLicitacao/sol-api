module ReportsService::Download
  class Base
    include TransactionMethods
    include Call::Methods

    def main_method
      execute
    end

    private

    def execute
      report.processing!

      download

      report.update!(url: name_file)
      report.success!

    rescue => error
      report.update!(
        error_message: error.message,
        error_backtrace: error.backtrace
      )

      report.error!
    end

    def download
      load_resources
      @book = Spreadsheet::Workbook.new
      @sheet = @book.create_worksheet(name: 'Sumário')
      @sheet.row(0).concat [sheet_row_first]
      @sheet.row(1).concat sheet_titles_columns
      load_rows
      detailings
      load_row_detailings
      @book.write name_file
    end

    def detailings
      @sheet1 = @book.create_worksheet(name: 'Detalhes')
    end

    def load_row_detailings; end

    def load_resources; end

    def worksheet_name; end

    def sheet_row_first; end

    def sheet_titles_columns; end

    def load_rows; end

    def format_money(value)
      ActionController::Base.helpers.number_to_currency(value)
    end

  end
end
