module BiddingsService::Download
  class Base
    include Call::Methods
    include PriceMethods
    include DeliveryMethods

    attr_accessor :book

    def initialize(*args)
      super
      @book = Spreadsheet::Write::Strategy.decide(file_type)
    end

    def main_method
      generate_file
    end

    private

    def generate_file
      fill_headers
      iterate_and_fill_rows
      book_clear_and_write
      file_path
    end

    def fill_headers
      %w[price delivery].each do |type|
        Base.const_get("HEADER_#{type.upcase}_COLUMNS").each_with_index do |columns, i|
          book.add_header(send("#{type}_sheet"), i, columns)
        end
      end
    end

    def iterate_and_fill_rows
      raise ImplementThisMethodError
    end

    def book_clear_and_write
      book.clear_sheets
      book.write(file_path)
    end

    def fill_row(type, row_index, *args)
      row_values = send("row_#{type}_values", *args)

      row_values.each_with_index do |value, column_index|
        book.add_cell(send("#{type}_sheet"), row_index + 2, column_index, value)
      end
    end

    def file_path
      @file_path ||=
        "storage/#{I18n.t('services.biddings.download.file_name')}_"\
        "#{Random.rand(99999)}_#{DateTime.current.strftime('%d%m%Y%H%M%S')}"\
        ".#{file_type}"
    end
  end
end
