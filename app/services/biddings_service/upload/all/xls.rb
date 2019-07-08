module BiddingsService::Upload::All
  class Xls < Base
    include BiddingsService::Upload::All::Concerns::XlsRows

    def book
      @book ||= Spreadsheet.open(import.file.url)
    end

    def sheet
      @sheet ||= book.worksheet(0)
    end

    def lot_sheet
      @lot_sheet ||= book.worksheet(1)
    end

    def row_delivery_price
      RowDeliveryPrice::Xls
    end

    def row_values
      RowValues::Xls
    end
  end
end
