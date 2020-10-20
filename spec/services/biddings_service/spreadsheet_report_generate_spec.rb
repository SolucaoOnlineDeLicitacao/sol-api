require 'rails_helper'

RSpec.describe BiddingsService::SpreadsheetReportGenerate, type: :service do
  let(:bidding) { create(:bidding) }
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call!' do
    let(:spreadsheet_report_generate_return) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/proposal_upload_1_1.xls")
      )
    end
    let(:report) do
      create(:report,
             admin: bidding.admin,
             report_type: :bidding_items,
             url: spreadsheet_report_generate_return.path)
    end

    before do
      allow(ReportsService::Biddings::Items::Download).
        to receive(:call).and_return(report)
      allow(Report).to receive(:create!).and_return(report)
    end

    subject { described_class.call!(params) }

    context 'when it runs successfully' do
      it { is_expected.to be_truthy }

      describe 'the spreadsheet_report' do
        before { subject }

        it { expect(bidding.spreadsheet_report).to be_present }
        it { expect(bidding.spreadsheet_report.file).to be_present }
      end

      context 'and the bidding already have a spreadsheet_report' do
        let(:spreadsheet_report) { create(:spreadsheet_document) }
        let(:bidding) do
          create(:bidding, spreadsheet_report: spreadsheet_report)
        end
        let(:spreadsheet_report_generate_return) do
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec/fixtures/myfiles/proposal_upload_1_2.xls")
          )
        end

        it { is_expected.to be_truthy }
        it { expect { subject }.to_not change { bidding.spreadsheet_report } }

        describe 'the spreadsheet_report' do
          before { subject }

          it do
            expect(bidding.spreadsheet_report.file.filename).
              to include('proposal_upload_1_2')
          end
        end
      end
    end

    context 'when it runs with failures' do
      let(:error) { ActiveRecord::RecordInvalid }

      context 'and SpreadsheetDocument.create! error' do
        before do
          allow(SpreadsheetDocument).to receive(:create!).and_raise(error)
        end

        it { expect { subject }.to raise_error(error) }
      end

      context 'and bidding.update! error' do
        before { allow(bidding).to receive(:update!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end
    end
  end
end
