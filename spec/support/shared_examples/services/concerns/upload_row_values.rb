RSpec.shared_examples 'services/concerns/upload_row_values' do
  context 'when locale is pt-BR' do
    describe '#initialize' do
      let(:price) { nil }
      let(:row) { [1, 2, nil, 3, nil, nil, nil, nil, price] }

      subject { described_class.new(row) }

      context 'when price' do
        context 'is nil' do
          it { expect(subject.price).to eq(nil) }
        end

        context 'is an int' do
          let!(:price) { 4 }

          it { expect(subject.price).to eq(4.0) }
        end

        context 'is a string' do
          let!(:price) { '4' }

          it { expect(subject.price).to eq(4.0) }

          context 'with R$' do
            let!(:price) { 'R$ 4' }

            it { expect(subject.price).to eq(4.0) }
          end

          context 'with R$ and comma' do
            let!(:price) { 'R$ 4,50' }

            it { expect(subject.price).to eq(4.5) }
          end

          context 'with R$ dot and comma' do
            let!(:price) { 'R$ 1.104,50' }

            it { expect(subject.price).to eq(1104.50) }
          end

          context 'with letters' do
            let!(:price) { 'R$ asb1.104,50' }

            it { expect(subject.price).to eq(1104.50) }
          end

          context 'empty' do
            let!(:price) { '' }

            it { expect(subject.price).to eq(nil) }
          end
        end
      end

      it { expect(subject.lot_group_item_id).to eq(3) }
    end
  end

  context 'when locale is en-US' do
    describe '#initialize' do
      let(:price) { nil }
      let(:row) { [1, 2, nil, 3, nil, nil, nil, nil, price] }

      before { I18n.default_locale = :'en-US' }

      subject { described_class.new(row) }

      after { I18n.default_locale = :'pt-BR' }

      context 'when price' do
        context 'is nil' do
          it { expect(subject.price).to eq(nil) }
        end

        context 'is an int' do
          let!(:price) { 4 }

          it { expect(subject.price).to eq(4.0) }
        end

        context 'is a string' do
          let!(:price) { '4' }

          it { expect(subject.price).to eq(4.0) }

          context 'with $' do
            let!(:price) { '$4' }

            it { expect(subject.price).to eq(4.0) }
          end

          context 'with $ and dot' do
            let!(:price) { '$4.50' }

            it { expect(subject.price).to eq(4.5) }
          end

          context 'with $ comma and dot' do
            let!(:price) { '$1,104.50' }

            it { expect(subject.price).to eq(1104.50) }
          end

          context 'with letters' do
            let!(:price) { '$asb1,104.50' }

            it { expect(subject.price).to eq(1104.50) }
          end

          context 'empty' do
            let!(:price) { '' }

            it { expect(subject.price).to eq(nil) }
          end
        end
      end

      it { expect(subject.lot_group_item_id).to eq(3) }
    end
  end
end
