require 'rails_helper'

RSpec.describe ReportsService::Bidding, type: :service do
  let(:service) { ReportsService::Bidding.new() }
  let(:service_call) { service.call }

  let!(:covenant) { create(:covenant) }
  let!(:bidding_1) { create(:bidding, covenant: covenant, status: 0, kind: 1) }
  let!(:bidding_2) { create(:bidding, covenant: covenant, status: 0, kind: 2) }

  describe 'call' do
    context 'without whitelisted bidding' do
      let(:report) {
        [
          { label: :waiting,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :approved,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :ongoing,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :draw,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :under_review,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :finnished,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :canceled,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :suspended,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :failure,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :reopened,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } },
          { label: :desert,  data: { countable: 0,  price_total: 0.0, estimated_cost: 0.0 } }
        ]
      }

      it { expect(service_call).to eq report }
    end

    context 'with whitelisted bidding' do
      context 'report' do
        described_class::STATUSES.each do |status|
          before { create_list(:bidding, 2, status: status, covenant: covenant, kind: rand(1..3)) }

          let!("estimated_cost_#{status}") { Bidding.send(status).joins(:group_items).sum('group_items.estimated_cost') }

          let!("price_total_#{status}") { Bidding.send(status).map(&:proposals).map(&:accepted).flatten.sum(&:price_total) }
        end

        let(:report) {
          [
            { label: :waiting,  data: { countable: 2,  price_total: price_total_waiting.to_f, estimated_cost: estimated_cost_waiting } },
            { label: :approved,  data: { countable: 2,  price_total: price_total_approved.to_f, estimated_cost: estimated_cost_approved } },
            { label: :ongoing,  data: { countable: 2,  price_total: price_total_ongoing.to_f, estimated_cost: estimated_cost_ongoing } },
            { label: :draw,  data: { countable: 2,  price_total: price_total_draw.to_f, estimated_cost: estimated_cost_draw } },
            { label: :under_review,  data: { countable: 2,  price_total: price_total_under_review.to_f, estimated_cost: estimated_cost_under_review } },
            { label: :finnished,  data: { countable: 2,  price_total: price_total_finnished.to_f, estimated_cost: estimated_cost_finnished } },
            { label: :canceled,  data: { countable: 2,  price_total: price_total_canceled.to_f, estimated_cost: estimated_cost_canceled } },
            { label: :suspended,  data: { countable: 2,  price_total: price_total_suspended.to_f, estimated_cost: estimated_cost_suspended } },
            { label: :failure,  data: { countable: 2,  price_total: price_total_failure.to_f, estimated_cost: estimated_cost_failure } },
            { label: :reopened,  data: { countable: 2,  price_total: price_total_reopened.to_f, estimated_cost: estimated_cost_reopened } },
            { label: :desert,  data: { countable: 2,  price_total: price_total_desert.to_f, estimated_cost: estimated_cost_desert } }
          ]
        }

        it { expect(service_call).to eq report }
      end

    end
  end
end
