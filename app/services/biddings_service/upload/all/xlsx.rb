module BiddingsService::Upload::All
  class Xlsx < Base
    include BiddingsService::Upload::All::Concerns::XlsxRows

    def book
      @book ||= RubyXL::Parser.parse(import.file.file.path)
    end

    def sheet
      @sheet ||= book[0]
    end

    def lot_sheet
      @lot_sheet ||= book[1]
    end

    def row_delivery_price
      RowDeliveryPrice::Xlsx
    end

    def row_values
      RowValues::Xlsx
    end
  end
end
