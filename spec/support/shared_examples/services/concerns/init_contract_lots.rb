RSpec.shared_examples 'services/concerns/init_contract_lot' do
  include_examples 'services/concerns/init_bidding_lot'

  let!(:contract) do
    create(:contract, proposal: proposal_c_lot_1, status: :signed, user: user, user_signed_at: DateTime.current)
  end
end
