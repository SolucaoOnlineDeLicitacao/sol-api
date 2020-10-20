require 'rails_helper'

RSpec.describe ReportsService::Biddings::Items::Download, type: :service do
  include ActionView::Helpers::NumberHelper

  describe '.call' do
    let(:report) { create(:report, report_type: :bidding_items) }
    let(:bidding) { create(:bidding, status: :under_review, kind: :global) }

    subject { described_class.call(report: report, bidding: bidding) }

    context 'when it runs successfully' do
      let(:file_xlsx) { Spreadsheet.open Dir[report.url].first }
      let(:sheet) { file_xlsx.worksheet 0 }

      before { subject }

      context 'and has no proposal' do
        let(:lot_group_item) { bidding.lot_group_items.first }

        describe 'file' do
          it { expect(report.success?).to be_truthy }
          it { expect(report.url).to match /storage\/licitacao_items_.*\.xls$/ }
          it { expect(report.error_message).to be_nil }
          it { expect(report.error_backtrace).to be_nil }
          it { expect(file_xlsx).to be_present  }
        end

        describe 'sheet header' do
          let(:expected_header_rows) do
            [
              [
                I18n.t('services.download.biddings.items.header_row_1'),
                "#{bidding.title} - #{bidding.description}"
              ],
              [
                I18n.t('services.download.biddings.items.header_row_2'),
                bidding.cooperative.name
              ],
              [
                I18n.t('services.download.biddings.items.header_row_3'),
                "#{bidding.covenant.number} - #{bidding.covenant.name}"
              ],
              [
                I18n.t('services.download.biddings.items.header_row_4'),
                I18n.t("services.download.biddings.status.kind.#{bidding.kind}")
              ],
              [
                I18n.t('services.download.biddings.items.header_row_5'),
                bidding.deadline
              ]
            ]
          end

          5.times do |i|
            it { expect(sheet.row(i)).to eq(expected_header_rows[i]) }
          end
        end

        describe 'sheet columns' do
          let(:column_names) do 
            8.times.inject([]) do |array, i|
              array << I18n.t("services.download.biddings.items.column_#{i+1}")
            end
          end
          let(:expected_column) do
            [
              lot_group_item.lot.name,
              lot_group_item.item.title,
              lot_group_item.item.description,
              ActionController::Base.helpers.number_to_currency(
                lot_group_item.group_item.estimated_cost
              ),
              number_with_delimiter(lot_group_item.quantity),
              nil,
              nil,
              nil
            ]
          end

          it { expect(sheet.row(6)).to eq(column_names) }
          it { expect(sheet.row(7)).to eq(expected_column) }
        end
      end

      context 'and has proposal' do
        let(:proposal) { create(:proposal) }
        let(:bidding) do
          create(:bidding,
                 status: :under_review,
                 kind: :global,
                 proposals: [proposal])
        end

        describe 'file' do
          it { expect(report.success?).to be_truthy }
          it { expect(report.url).to match /storage\/licitacao_items_.*\.xls$/ }
          it { expect(report.error_message).to be_nil }
          it { expect(report.error_backtrace).to be_nil }
          it { expect(file_xlsx).to be_present  }
        end

        describe 'sheet header' do
          let(:expected_header_rows) do
            [
              [
                I18n.t('services.download.biddings.items.header_row_1'),
                "#{bidding.title} - #{bidding.description}"
              ],
              [
                I18n.t('services.download.biddings.items.header_row_2'),
                bidding.cooperative.name
              ],
              [
                I18n.t('services.download.biddings.items.header_row_3'),
                "#{bidding.covenant.number} - #{bidding.covenant.name}"
              ],
              [
                I18n.t('services.download.biddings.items.header_row_4'),
                I18n.t("services.download.biddings.status.kind.#{bidding.kind}")
              ],
              [
                I18n.t('services.download.biddings.items.header_row_5'),
                bidding.deadline
              ]
            ]
          end

          5.times do |i|
            it { expect(sheet.row(i)).to eq(expected_header_rows[i]) }
          end
        end

        describe 'sheet columns' do
          let(:column_names) do 
            8.times.inject([]) do |array, i|
              array << I18n.t("services.download.biddings.items.column_#{i+1}")
            end
          end
          let(:expected_column) do
            lot_group_item_lot_proposal =
              proposal.lot_group_item_lot_proposals.last 
            lot_group_item = lot_group_item_lot_proposal.lot_group_item

            [
              lot_group_item.lot.name,
              lot_group_item.item.title,
              lot_group_item.item.description,
              ActionController::Base.helpers.number_to_currency(
                lot_group_item.group_item.estimated_cost
              ),
              number_with_delimiter(lot_group_item.quantity),
              ActionController::Base.helpers.number_to_currency(
                lot_group_item_lot_proposal.price
              ),
              ActionController::Base.helpers.number_to_currency(
                proposal.price_total
              ),
              proposal.provider.name
            ]
          end

          it { expect(sheet.row(6)).to eq(column_names) }
          it { expect(sheet.row(7)).to eq(expected_column) }
        end
      end
    end

    context 'when it runs with failures' do
      before do
        allow_any_instance_of(described_class).
          to receive(:download).and_raise(ActiveRecord::RecordInvalid)
        subject
      end

      it { expect(report.error?).to be_truthy }
      it { expect(report.url).to be_nil }
      it { expect(report.error_message).to be_present }
      it { expect(report.error_backtrace).to be_present }
    end
  end
end
