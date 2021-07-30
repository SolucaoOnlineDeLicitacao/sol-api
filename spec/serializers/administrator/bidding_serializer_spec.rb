require 'rails_helper'

RSpec.describe Administrator::BiddingSerializer, type: :serializer do
  it_behaves_like 'a bidding_serializer' do
    describe 'extra attributes' do
      let(:spreadsheet_report) { create(:spreadsheet_document) }
      let(:object) do
        create :bidding, merged_minute_document: merged_minute_document,
                         edict_document: edict_document,
                         spreadsheet_report: spreadsheet_report
      end

      it { expect(subject['spreadsheet_report']).to include('.xls')}
    end
  end
end
