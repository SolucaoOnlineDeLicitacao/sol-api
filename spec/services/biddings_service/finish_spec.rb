require 'rails_helper'

RSpec.describe BiddingsService::Finish, type: :service do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user) }
  let(:lot) { create(:lot, status: :accepted) }
  let!(:bidding) do
    create(:bidding, covenant: covenant, build_lot: false, lots: [lot],
                     status: :under_review)
  end
  let!(:proposal_1) do
    create(:proposal, bidding: bidding, lot: lot, status: :draw)
  end
  let!(:proposal_2) do
    create(:proposal, bidding: bidding, lot: lot, status: :sent)
  end
  let(:params) { { bidding: bidding, user: user } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.user).to eq user }
  end

  describe '.call' do
    let(:worker) { Bidding::Minute::PdfGenerateWorker }
    let(:api_response) { double('api_response', success?: true) }

    before do
      allow(RecalculateQuantityService).
        to receive(:call!).with(covenant: bidding.covenant).and_return(true)
      allow(ContractsService::Create::Strategy::Finnished).
        to receive(:call!).with(params).and_return(true)
      allow(Blockchain::Bidding::Update).
        to receive(:call).with(bidding).and_return(api_response)
      allow(Notifications::Biddings::Finished).
        to receive(:call).with(bidding).and_return(true)
      allow(Notifications::Proposals::Suppliers::All).
        to receive(:call).with(proposals: bidding.proposals).and_return(true)
      allow(BiddingsService::Clone).
        to receive(:call!).with(bidding: bidding).and_return(true)
    end

    subject { described_class.call(params) }

    context 'when success' do
      context 'and bidding have proposals' do
        before do
          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_truthy }
        it do
          expect(RecalculateQuantityService).
            to have_received(:call!).with(covenant: bidding.covenant)
        end
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            to have_received(:call!).with(params)
        end
        it do
          expect(Blockchain::Bidding::Update).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(1) }
      end

      context 'and bidding havent proposals' do
        before do
          bidding.proposals.map(&:draft!)
          subject
          bidding.reload
        end

        it { expect(bidding.desert?).to be_truthy }
        it do
          expect(RecalculateQuantityService).
            to have_received(:call!).with(covenant: bidding.covenant)
        end
        it do
          expect(Blockchain::Bidding::Update).
            to have_received(:call).with(bidding)
        end
        it do
          expect(BiddingsService::Clone).
            to have_received(:call!).with(bidding: bidding)
        end
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(1) }
      end
    end

    context 'when error' do
      context 'and bidding is not under_review' do
        before do
          bidding.draft!
          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(RecalculateQuantityService).
            not_to have_received(:call!).with(covenant: bidding.covenant)
        end
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and lots are not accepted, desert or failure' do
        before do
          bidding.lots.map(&:triage!)
          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(RecalculateQuantityService).
            not_to have_received(:call!).with(covenant: bidding.covenant)
        end
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and bidding is not under_review and lots are not accepted, desert or failure' do
        before do
          bidding.draft!
          bidding.lots.map(&:triage!)
          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(RecalculateQuantityService).
            not_to have_received(:call!).with(covenant: bidding.covenant)
        end
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and recalculate quantity has errors' do
        before do
          allow(RecalculateQuantityService).
            to receive(:call!).with(covenant: bidding.covenant).
            and_raise(RecalculateItemError)

          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and bidding has errors' do
        before do
          allow(bidding).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and contract create has errors' do
        before do
          allow(ContractsService::Create::Strategy::Finnished).
            to receive(:call!).with(params).
            and_raise(ActiveRecord::RecordInvalid)

          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and blockchain has errors' do
        let(:api_response) { double('api_response', success?: false) }

        before do
          subject
          bidding.reload
        end

        it { expect(bidding.finnished?).to be_falsey }
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and bidding havent proposals and clone has errors' do
        before do
          allow(BiddingsService::Clone).
            to receive(:call!).with(bidding: bidding).
            and_raise(ActiveRecord::RecordInvalid)

          bidding.proposals.map(&:draft!)
          subject
          bidding.reload
        end

        it { expect(bidding.desert?).to be_falsey }
        it do
          expect(ContractsService::Create::Strategy::Finnished).
            not_to have_received(:call!).with(params)
        end
        it do
          expect(Notifications::Biddings::Finished).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
