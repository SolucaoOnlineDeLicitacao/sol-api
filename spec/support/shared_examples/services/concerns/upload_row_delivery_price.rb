RSpec.shared_examples 'services/concerns/upload_row_delivery_price' do |type|
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:params) { { lot: lot, sheet: sheet } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.lot).to eq(lot) }
    it { expect(subject.sheet).to eq(sheet) }
  end

  context 'when locale is pt-BR' do
    describe '.call' do
      let(:xls_type?) { type == 'xls' }

      before do
        if xls_type?
          sheet.row(2)[0] = lot_id
          sheet.row(2)[4] = delivery_price
        else
          sheet[2][0].change_contents(lot_id)
          sheet[2][4].change_contents(delivery_price)
        end
      end

      subject { described_class.call(params) }

      context 'when have lot at sheet' do
        let(:lot_id) { lot.id }

        describe 'delivery_price' do
          context 'when is valid' do
            context 'and is string with integer' do
              let(:delivery_price) { '123' }

              it { is_expected.to eq(123.0) }
            end
            context 'and is string with float' do
              let(:delivery_price) { '1.234,5' }

              it { is_expected.to eq(1234.5) }
            end
            context 'and is string with float' do
              let(:delivery_price) { '123.5' }

              it { is_expected.to eq(1235.0) }
            end
            context 'and is integer' do
              let(:delivery_price) { 123 }

              it { is_expected.to eq(123) }
            end
            context 'and is float' do
              let(:delivery_price) { 123.5 }

              it { is_expected.to eq(1235.0) }
            end
          end

          context 'when is invalid' do
            context 'and is nil' do
              let(:delivery_price) { nil }

              it { is_expected.to eq(nil) }
            end
            context 'and is empty' do
              let(:delivery_price) { '' }

              it { is_expected.to eq(nil) }
            end
            context 'and is string' do
              let(:delivery_price) { 'asd123' }

              it { is_expected.to eq(123.0) }
            end
          end
        end
      end

      context 'when not have lot at sheet' do
        let(:delivery_price) { '123.5' }

        describe 'lot' do
          context 'when is valid' do
            let(:lot_id) { 0 }

            it { is_expected.to eq(nil) }
          end
          context 'when is invalid' do
            context 'and is nil' do
              let(:lot_id) { nil }

              it { is_expected.to eq(nil) }
            end
            context 'and is empty' do
              let(:lot_id) { '' }

              it { is_expected.to eq(nil) }
            end
            context 'and is string' do
              let(:lot_id) { 'asd123' }

              it { is_expected.to eq(nil) }
            end
          end
        end
      end
    end
  end

  context 'when locale is en-US' do
    describe '.call' do
      let(:xls_type?) { type == 'xls' }

      before do
        I18n.default_locale = :'en-US'

        if xls_type?
          sheet.row(2)[0] = lot_id
          sheet.row(2)[4] = delivery_price
        else
          sheet[2][0].change_contents(lot_id)
          sheet[2][4].change_contents(delivery_price)
        end
      end

      subject { described_class.call(params) }

      after { I18n.default_locale = :'pt-BR' }

      context 'when have lot at sheet' do
        let(:lot_id) { lot.id }

        describe 'delivery_price' do
          context 'when is valid' do
            context 'and is string with integer' do
              let(:delivery_price) { '123' }

              it { is_expected.to eq(123.0) }
            end
            context 'and is string with float' do
              let(:delivery_price) { '1,234.5' }

              it { is_expected.to eq(1234.5) }
            end
            context 'and is string with float' do
              let(:delivery_price) { '123,5' }

              it { is_expected.to eq(1235.0) }
            end
            context 'and is integer' do
              let(:delivery_price) { 123 }

              it { is_expected.to eq(123) }
            end
            context 'and is float' do
              let(:delivery_price) { 123.5 }

              it { is_expected.to eq(123.5) }
            end
          end

          context 'when is invalid' do
            context 'and is nil' do
              let(:delivery_price) { nil }

              it { is_expected.to eq(nil) }
            end
            context 'and is empty' do
              let(:delivery_price) { '' }

              it { is_expected.to eq(nil) }
            end
            context 'and is string' do
              let(:delivery_price) { 'asd123' }

              it { is_expected.to eq(123.0) }
            end
          end
        end
      end

      context 'when not have lot at sheet' do
        let(:delivery_price) { '123,5' }

        describe 'lot' do
          context 'when is valid' do
            let(:lot_id) { 0 }

            it { is_expected.to eq(nil) }
          end
          context 'when is invalid' do
            context 'and is nil' do
              let(:lot_id) { nil }

              it { is_expected.to eq(nil) }
            end
            context 'and is empty' do
              let(:lot_id) { '' }

              it { is_expected.to eq(nil) }
            end
            context 'and is string' do
              let(:lot_id) { 'asd123' }

              it { is_expected.to eq(nil) }
            end
          end
        end
      end
    end
  end
end
