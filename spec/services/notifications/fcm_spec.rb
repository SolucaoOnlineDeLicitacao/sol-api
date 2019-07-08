require 'rails_helper'

RSpec.describe Notifications::Fcm, type: [:service, :notification] do
  let!(:bidding)      { create(:bidding, kind: :global, status: :approved) }
  let(:service)       { described_class.new(notification.id) }

  let(:covenant)      { bidding.covenant }
  let(:cooperative)   { covenant.cooperative }
  let!(:user)         { create(:user, cooperative: cooperative) }
  let!(:device_token) { create(:device_token, owner: user) }
  let!(:admin)        { covenant.admin }

  let(:notification) do
    create(:notification, receivable: user, notifiable: bidding)
  end

  describe '#initialize' do
    it { expect(service.notification).to eq notification }
  end

  describe 'fcm setup' do
    let(:key) { 'abc' }

    before do
      allow(Rails.application.secrets).to receive(:dig).with(:firebase, :server_key) { key }
      allow(FCM).to receive(:new).with(key).and_call_original

      service.call
    end

    it { expect(FCM).to have_received(:new).with(key) }
  end

  describe 'delegations' do
    subject { service }

    it { is_expected.to delegate_method(:receivable).to(:notification) }
    it { is_expected.to delegate_method(:notifiable).to(:notification) }
    it { is_expected.to delegate_method(:action).to(:notification) }
    it { is_expected.to delegate_method(:title_args).to(:notification) }
    it { is_expected.to delegate_method(:body_args).to(:notification) }
    it { is_expected.to delegate_method(:extra_args).to(:notification) }
  end

  describe '#call' do
    subject { described_class }

    before do
      allow(subject).to receive_message_chain(:new, :call)

      subject.call(notification.id)
    end

    it { expect(subject.new(notification.id)).to have_received(:call) }
  end

  describe '.delay.call' do
    before { subject }

    subject { described_class.delay.call(notification.id) }

    it do
      expect(described_class.instance_method :call).
        to be_delayed(notification.id)
    end
  end

  describe '.call' do
    subject { service.call }

    context 'when not allowed_to_send' do
      let(:fcm) { FCM.new('key') }

      before do
        notification.receivable = admin
        notification.save

        allow(service).to receive(:fcm) { fcm }
        allow(fcm).to receive(:send)

        subject
      end

      it { expect(fcm).not_to have_received(:send) }
      it do
        expect(described_class.instance_method :call).
          not_to be_delayed(notification.id)
      end
    end

    context 'when allowed_to_send' do
      let(:fcm) { FCM.new('key') }
      let(:tokens) { user.device_tokens.pluck(:body) }

      before { allow(service).to receive(:fcm) { fcm } }

      describe 'attributes' do
        let(:response) { { not_registered_ids: [] } }

        let(:attributes) do
          {
            "data": {
              title: service.send(:locale_sanitize, :title, notification.title_args),
              body: service.send(:locale_sanitize, :body, notification.body_args),
              id: notification.id,
              action: notification.action,
              notifiable_id: notification.notifiable_id,
              args: notification.extra_args
            }
          }
        end

        before do
          allow(fcm).to receive(:send).with(tokens, attributes) { response }

          subject
        end

        it { expect(fcm).to have_received(:send).with(tokens, attributes) }
      end

      context 'when not_registered_ids' do
        let!(:response) { { not_registered_ids: tokens } }
        let!(:another_token) { create(:device_token ) }

        before do
          allow(fcm).to receive(:send) { response }

          subject
        end

        it { expect(user.device_tokens).to be_empty }
      end
    end
  end
end
