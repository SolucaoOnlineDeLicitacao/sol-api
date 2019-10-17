module Spreadsheet::Write
  class Xlsx
    attr_accessor :book

    FILE_EXTENSION = 'xlsx'.freeze

    def initialize
      @book = RubyXL::Workbook.new
    end

    def create_sheet(name)
      book.add_worksheet(name)
    end

    def write(file_path)
      book.write(file_path)
    end

    def add_header(sheet, line, columns)
      columns.each_with_index do |value, column|
        sheet.add_cell(line, column, value)
      end
    end

    def add_cell(sheet, line, column, value)
      sheet.add_cell(line, column, value)
    end

    def concat_row(sheet, row, values)
      raise NotImplementedError
    end

    def replace_row(sheet, row, values)
      raise NotImplementedError
    end

    def file_extension
      self.class::FILE_EXTENSION
    end

    def clear_sheets
      book.worksheets.shift
    end
  end
end
