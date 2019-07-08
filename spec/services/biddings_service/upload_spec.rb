require 'rails_helper'

RSpec.describe BiddingsService::Upload, type: :service do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }

  let(:import) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:notification_class) { 'Notifications::ProposalImports' }
  let(:notification_type) { nil }
  let(:params) do
    {
      user_id: user.id,
      import_model: import.class,
      import_id: import.id,
      notification_class: notification_class,
      notification_type: notification_type
    }
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.user_id).to eq user.id }
    it { expect(subject.import_model).to eq import.class }
    it { expect(subject.import_id).to eq import.id }
    it { expect(subject.notification_class).to eq notification_class }
    it { expect(subject.notification_type).to eq notification_type }
    it { expect(subject.user).to eq user }
    it { expect(subject.import).to eq import }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when is proposal import type' do
      let(:notification_args) { { proposal_import: import, supplier: user } }

      before do
        allow(BiddingsService::Upload::All::Strategy).
          to receive(:decide).
          with(user: user, import: import).
          send(*service_response)

        allow(notification).
          to receive(:send).
          with(:call, notification_args).
          and_return(true)

        subject
        import.reload
      end

      context 'when success' do
        let(:service_response) { [:and_return, double(call!: true)] }
        let(:notification) { "#{notification_class}::Success".constantize }

        it { expect(import.status).to eq('success') }
        it { expect(import.error_message).to_not be_present }
        it { expect(import.error_backtrace).to_not be_present }
        it do
          expect(BiddingsService::Upload::All::Strategy).
            to have_received(:decide).
            with(user: user, import: import)
        end
        it do
          expect(notification).
            to have_received(:send).with(:call, notification_args)
        end
      end

      context 'when has errors' do
        let(:service_response) { [:and_raise, ActiveRecord::RecordInvalid] }
        let(:notification) { "#{notification_class}::Error".constantize }

        it { expect(import.status).to eq('error') }
        it { expect(import.error_message).to be_present }
        it { expect(import.error_backtrace).to be_present }
        it do
          expect(BiddingsService::Upload::All::Strategy).
            to have_received(:decide).
            with(user: user, import: import)
        end
        it do
          expect(notification).
            to have_received(:send).with(:call, notification_args)
        end
      end
    end

    context 'when is lot proposal import type' do
      let(:import) do
        create(:lot_proposal_import, bidding: bidding, provider: provider)
      end
      let(:notification_class) { 'Notifications::ProposalImports::Lots' }
      let(:notification_type) { 'lot_' }
      let(:notification_args) do
        { lot_proposal_import: import, supplier: user }
      end

      before do
        allow(BiddingsService::Upload::All::Strategy).
          to receive(:decide).
          with(user: user, import: import).
          send(*service_response)

        allow(notification).
          to receive(:send).
          with(:call, notification_args).
          and_return(true)

        subject
        import.reload
      end

      context 'when success' do
        let(:service_response) { [:and_return, double(call!: true)] }
        let(:notification) { "#{notification_class}::Success".constantize }

        it { expect(import.status).to eq('success') }
        it { expect(import.error_message).to_not be_present }
        it { expect(import.error_backtrace).to_not be_present }
        it do
          expect(BiddingsService::Upload::All::Strategy).
            to have_received(:decide).
            with(user: user, import: import)
        end
        it do
          expect(notification).
            to have_received(:send).with(:call, notification_args)
        end
      end

      context 'when has errors' do
        let(:service_response) { [:and_raise, ActiveRecord::RecordInvalid] }
        let(:notification) { "#{notification_class}::Error".constantize }

        it { expect(import.status).to eq('error') }
        it { expect(import.error_message).to be_present }
        it { expect(import.error_backtrace).to be_present }
        it do
          expect(BiddingsService::Upload::All::Strategy).
            to have_received(:decide).
            with(user: user, import: import)
        end
        it do
          expect(notification).
            to have_received(:send).with(:call, notification_args)
        end
      end
    end
  end
end
