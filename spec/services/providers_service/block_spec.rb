require 'rails_helper'

RSpec.describe ProvidersService::Block, type: :service do
  let(:user) { create(:admin) }
  let(:provider) { create(:provider, type: 'Provider', blocked: false) }
  let(:comment) { 'a comment' }
  let(:params) { { creator: user, provider: provider, comment: comment } }
  let(:event) do
    create(:event_provider_access, eventable: provider, creator: user, blocked: 1)
  end
  let(:event_response) { double('call!', call!: true, event: event) }

  before do
    allow(EventServices::Provider::Block).
      to receive(:new).with(params).and_return(event_response)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.provider).to eq provider }
    it { expect(subject.creator).to eq user }
    it { expect(subject.comment).to eq comment }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when success' do
      before { subject }

      it { is_expected.to be_truthy }
      it { expect(provider.blocked).to be_truthy }
      it do
        expect(EventServices::Provider::Block).
          to have_received(:new).with(params)
      end
    end

    context 'when error' do
      context 'and RecordInvalid' do
        before do
          allow(provider).
            to receive(:update!) { raise ActiveRecord::RecordInvalid }

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(provider.blocked).to be_falsey }
        it do
          expect(EventServices::Provider::Block).
            not_to have_received(:new).with(params)
        end
      end

      context 'and event error' do
        before do
          allow(EventServices::Provider::Block).
            to receive(:new).with(params).
            and_raise(ActiveRecord::RecordInvalid)

          subject
          provider.reload
        end

        it { is_expected.to be_falsey }
        it { expect(provider.blocked).to be_falsey }
      end
    end
  end
end
