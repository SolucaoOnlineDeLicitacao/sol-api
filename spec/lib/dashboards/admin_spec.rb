require 'rails_helper'
require './lib/dashboards/admin'

RSpec.describe Dashboards::Admin, type: :service do
  let(:serializer) { NotificationSerializer }
  let(:user) { create :admin }
  let!(:cooperatives) { create_list(:cooperative, 2) }
  let!(:provider) { create(:provider) }
  let!(:notifications) do
    create_list(:notification, 3, receivable: user, notifiable: user)
  end
  let(:bounds_params) do
    { south: '0.0', west: '0.0', north: '0.0', east: '0.0' }
  end
  let(:params) { { admin: user, bounds_params: bounds_params } }
  let(:service) { described_class.new(params) }

  before { allow(Bidding).to receive(:in_progress_count).and_return(7) }

  describe 'constants' do
    it { expect(described_class::NOTIFICATION_LIMIT).to eq 2 }
    it do
      expect(described_class::BOUNDS_DEFAULT).
        to eq({ south: 0.0, west: 0.0, north: 0.0, east: 0.0 })
    end
  end

  describe '#initialize' do
    subject { service }

    it { expect(subject.admin).to eq user }
    it { expect(subject.bounds_params).to eq bounds_params }
  end

  describe '#to_json' do
    subject { service.to_json }

    describe 'totals' do
      it { expect(subject[:cooperatives_total]).to eq Cooperative.count }
      it { expect(subject[:providers_total]).to be_present }
      it { expect(subject[:ongoing_licitations_total]).to eq 7 }
    end

    describe 'markers' do
      context 'without bounds in params' do
        it { expect(subject[:markers]).to eq [] }
      end

      context 'with bounds in params' do
        let(:north) { provider.address.latitude }
        let(:south) { provider.address.latitude }
        let(:west) { provider.address.longitude }
        let(:east) { provider.address.longitude }
        let(:bounds_params) do
          { south: south, west: west, north: north, east: east }
        end
        let(:markers_expected) do
          {
            position: {
              lat: provider.address.latitude.to_f,
              lng: provider.address.longitude.to_f
            },
            id: provider.id,
            text: provider.name,
            title: provider.name,
            type: 'provider'
          }
        end

        it { expect(subject[:markers]).to eq [markers_expected] }
      end
    end

    describe 'notifications' do
      let(:notifications_by_user) do
        Notification.by_receivable(user).sorted.limit(2)
      end
      let(:expected) do
        notifications_by_user.map do |notification|
          serializer.new(notification)
        end
      end

      it { expect(subject[:notifications].to_json).to eq expected.to_json }
    end

    context 'without required param' do
      let(:bounds_params) { { west: '0.0', north: '0.0', east: '0.0' } }

      it { is_expected.to be_falsey }
    end
  end
end
