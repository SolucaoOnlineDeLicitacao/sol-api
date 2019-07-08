RSpec.shared_examples "lib/contract/classifications" do |template|
  
  context 'when bidding is global kind' do
    include_examples 'services/concerns/init_contract'

    let(:covenant) { bidding.covenant }
    let(:cooperative) { covenant.cooperative }
    let(:user) { create(:user, cooperative: cooperative) }
    let(:admin) { create(:admin) }
    let!(:contract) do
      create(:contract, proposal: proposal,
                        user: user, user_signed_at: DateTime.current,
                        supplier: supplier, supplier_signed_at: DateTime.current)
    end
    let(:params) { { contract: contract } }

    describe '#initialize' do
      subject { described_class.new(params) }

      it { expect(subject.template).to eq(template) }
      it { expect(subject.contract).to eq(contract) }
      it { expect(subject.html).to be_present }
      it { expect(subject.table).to be_present }
    end

    describe '.call' do
      subject { described_class.call(params) }

      context 'when all_signed' do
        it { is_expected.not_to include("@@") }

        after do
          File.write(
            Rails.root.join("spec/fixtures/myfiles/global_#{template}"),
            subject
          )
        end
      end

      context 'when not all_signed' do
        let!(:contract) { create(:contract, proposal: proposal) }

        it { is_expected.to be_nil }
      end
    end
  end

  context 'when bidding is lot kind' do
    include_examples 'services/concerns/init_contract_lot'

    let(:bidding) { bidding_lot } 
    let(:proposal) { proposal_c_lot_1 } 
    let(:covenant) { bidding.covenant }
    let(:provider) { create(:provider) }
    let(:supplier) { create(:supplier, provider: provider) }
    let(:cooperative) { covenant.cooperative }
    let(:user) { create(:user, cooperative: cooperative) }
    let(:admin) { create(:admin) }
    let!(:contract) do
      create(:contract, proposal: proposal,
                        user: user, user_signed_at: DateTime.current,
                        supplier: supplier, supplier_signed_at: DateTime.current)
    end
    let(:params) { { contract: contract } }

    describe '#initialize' do
      subject { described_class.new(params) }

      it { expect(subject.template).to eq(template) }
      it { expect(subject.contract).to eq(contract) }
      it { expect(subject.html).to be_present }
      it { expect(subject.table).to be_present }
    end

    describe '.call' do
      subject { described_class.call(params) }

      context 'when all_signed' do
        it { is_expected.not_to include("@@") }

        after do
          File.write(
            Rails.root.join("spec/fixtures/myfiles/lot_#{template}"),
            subject
          )
        end
      end

      context 'when not all_signed' do
        let!(:contract) { create(:contract, proposal: proposal) }

        it { is_expected.to be_nil }
      end
    end
  end
  
end
