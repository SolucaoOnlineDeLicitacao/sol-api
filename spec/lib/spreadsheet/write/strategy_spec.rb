require 'rails_helper'

RSpec.describe Spreadsheet::Write::Strategy do
  describe '.decide' do
    subject { described_class.decide(file_type) }

    context 'when xls' do
      let(:file_type) { 'xls' }

      it { is_expected.to be_instance_of(Spreadsheet::Write::Xls) }
    end

    context 'when xlsx' do
      let(:file_type) { 'xlsx' }

      it { is_expected.to be_instance_of(Spreadsheet::Write::Xlsx) }
    end
  end
end
