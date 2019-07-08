module Spreadsheet::Write
  class Xls
    attr_accessor :book

    def initialize
      @book = Spreadsheet::Workbook.new
    end

    def create_sheet(name)
      book.create_worksheet(name: name)
    end

    def write(file_path)
      book.write(file_path)
    end

    def add_header(sheet, line, columns)
      sheet.row(line).concat columns
    end

    def add_cell(sheet, line, column, value)
      sheet.row(line)[column] = value
    end

    def clear_sheets; end
  end
end
