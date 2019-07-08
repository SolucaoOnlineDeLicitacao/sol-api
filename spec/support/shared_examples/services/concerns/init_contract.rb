RSpec.shared_examples 'services/concerns/init_contract' do
  let!(:user) { create(:user) }
  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let!(:classification) { create(:classification, name: 'BENS') }
  let!(:bidding) { create(:bidding, status: :finnished, kind: :global, classification: classification) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal, status: :signed, user: user, user_signed_at: DateTime.current)
  end
end
