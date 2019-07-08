RSpec.shared_examples 'services/concerns/init_bidding_lot' do
  let!(:user) { create(:user) }

  let!(:bidding_lot) { create(:bidding, kind: :lot, description: "Bidding Lot" ) }
  let!(:lot_1) { bidding_lot.lots.first }
  let!(:lot_2) { create(:lot, bidding: bidding_lot) }
  let!(:lot_3) { create(:lot, bidding: bidding_lot) }
  let!(:proposal_a_lot_1) do
    create(:proposal, bidding: bidding_lot, lot: lot_1, status: :sent, price_total: 5001,
      sent_updated_at: DateTime.now)
  end

  let!(:proposal_b_lot_1) do
    create(:proposal, bidding: bidding_lot, lot: lot_1, status: :sent, price_total: 5000,
      sent_updated_at: DateTime.now+1.day)
  end

  let!(:proposal_c_lot_1) do
    create(:proposal, bidding: bidding_lot, lot: lot_1, status: :accepted, price_total: 6000)
  end

  let!(:proposal_a_lot_2) do
    create(:proposal, bidding: bidding_lot, lot: lot_2, status: :triage, price_total: 1001,
      sent_updated_at: DateTime.now)
  end

  let!(:proposal_b_lot_2) do
    create(:proposal, bidding: bidding_lot, lot: lot_2, status: :accepted, price_total: 1000,
      sent_updated_at: DateTime.now+1.day)
  end

  let!(:proposal_c_lot_2) do
    create(:proposal, bidding: bidding_lot, lot: lot_2, status: :triage, price_total: 2000)
  end

  let!(:proposal_a_lot_3) do
    create(:proposal, bidding: bidding_lot, lot: lot_3, status: :accepted, price_total: 999,
      sent_updated_at: DateTime.now)
  end

  let!(:proposal_b_lot_3) do
    create(:proposal, bidding: bidding_lot, lot: lot_3, status: :triage, price_total: 1000,
      sent_updated_at: DateTime.now+1.day)
  end

  let!(:proposal_c_lot_3) do
    create(:proposal, bidding: bidding_lot, lot: lot_3, status: :triage, price_total: 2000)
  end
end