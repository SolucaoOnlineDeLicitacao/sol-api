RSpec.shared_examples 'services/concerns/download' do |proposal, file_type|
  let(:file_name) { I18n.t('services.biddings.download.file_name') }
  let(:lot) { create(:lot) }
  let(:another_lot) { create(:lot) }
  let(:bidding) { create(:bidding, build_lot: false, lots: [lot, another_lot]) }
  let(:book_instance) do
    if file_type == 'xls'
      Spreadsheet::Write::Xls
    else
      Spreadsheet::Write::Xlsx
    end
  end
  let(:base_params) { { bidding: bidding, file_type: file_type } }
  let(:proposal_lot?) { proposal == 'lot' }
  let(:params) { proposal_lot? ? base_params.merge(lot: lot) : base_params }
  let(:path) do
    "storage/**/#{file_name}_#{fix_value}_#{date_time.strftime('%d%m%Y%H%M%S')}"
  end
  let(:date_time) { DateTime.new(2015, 7, 19, 13, 40, 00) }
  let(:fix_value) { 12345 }

  context 'when locale is pt-BR' do
    before do
      allow(DateTime).to receive(:current).and_return(date_time)
      allow(Random).to receive(:rand).with(99999).and_return(fix_value)

      subject
    end

    include_examples "services/concerns/download_asserts", proposal, file_type
  end

  context 'when locale is en-US' do
    before do
      I18n.default_locale = :'en-US'
      I18n.locale = :'en-US'

      allow(DateTime).to receive(:current).and_return(date_time)
      allow(Random).to receive(:rand).with(99999).and_return(fix_value)

      subject
    end

    after do
      I18n.default_locale = :'pt-BR'
      I18n.locale = :'pt-BR'
    end

    include_examples "services/concerns/download_asserts", proposal, file_type
  end
end
