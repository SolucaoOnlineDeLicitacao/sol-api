require 'rails_helper'

RSpec.describe Spreadsheet::Write::Xlsx do
  let(:instance) { described_class.new }
  let(:sheet) { instance.create_sheet('foo') }

  describe '#initialize' do
    subject { instance.book }

    it { is_expected.to be_instance_of(RubyXL::Workbook) }
  end

  describe '#create_sheet' do
    subject { sheet.sheet_name }

    it { is_expected.to eq('foo') }
  end

  describe '#write' do
    subject { instance.write(Rails.root.join('storage/spreadsheet_write.xlsx')) }

    it { is_expected.to be_present }
  end

  describe '#add_header' do
    subject { instance.add_header(sheet, 0, ['foo', 'bar']) }

    it { expect(subject.first).to eq('foo') }
    it { expect(subject.last).to eq('bar') }
  end

  describe '#add_cell' do
    subject { instance.add_cell(sheet, 0, 0, 'foo').value }

    it { is_expected.to eq('foo') }
  end

  describe '#clear_sheets' do
    subject do
      sheet
      instance.clear_sheets
    end

    it { expect(instance.book.worksheets.size).to eq(1) }
  end
end
