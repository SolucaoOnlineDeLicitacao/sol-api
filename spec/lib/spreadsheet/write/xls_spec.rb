require 'rails_helper'

RSpec.describe Spreadsheet::Write::Xls do
  let(:instance) { described_class.new }
  let(:sheet) { instance.create_sheet('foo') }

  describe '#initialize' do
    subject { instance.book }

    it { is_expected.to be_instance_of(Spreadsheet::Workbook) }
  end

  describe '#create_sheet' do
    subject { sheet.name }

    it { is_expected.to eq('foo') }
  end

  describe '#write' do
    before do
      instance.add_header(sheet, 0, ['foo', 'bar'])

      subject
    end

    subject { instance.write(Rails.root.join('storage/spreadsheet_write.xls')) }

    it { is_expected.to be_present }
  end

  describe '#add_header' do
    subject { instance.add_header(sheet, 0, ['foo', 'bar']) }

    it { expect(subject.first).to eq('foo') }
    it { expect(subject.last).to eq('bar') }
  end

  describe '#add_cell' do
    subject { instance.add_cell(sheet, 0, 0, 'foo') }

    it { is_expected.to eq('foo') }
  end

  describe '#clear_sheets' do
    subject { instance.clear_sheets }

    it { is_expected.to be_nil }
  end
end
