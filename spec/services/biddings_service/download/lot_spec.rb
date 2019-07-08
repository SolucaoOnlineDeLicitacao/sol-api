require 'rails_helper'

RSpec.describe BiddingsService::Download::Lot, type: :service do
  context 'when xls' do
    def sheet_cell(row, column)
      sheet.row(row)[column]
    end

    def sheet_row(number)
      sheet.row(number)
    end

    let(:file) { Spreadsheet.open(Dir["#{path}.xls"].first) }
    let(:sheet) { file.worksheet(sheet_number) }

    include_examples 'services/concerns/download', 'lot', 'xls'
  end

  context 'when xlsx' do
    def sheet_cell(row, column)
      sheet[row][column].value
    end

    def sheet_row(number)
      sheet[number].blank? ? [] : sheet[number]
    end

    let(:file) { RubyXL::Parser.parse(Dir["#{path}.xlsx"].first) }
    let(:sheet) { file.worksheets[sheet_number] }

    include_examples 'services/concerns/download', 'lot', 'xlsx'
  end
end
