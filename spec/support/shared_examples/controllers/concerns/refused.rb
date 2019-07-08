RSpec.shared_examples 'controller/concerns/refused' do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let!(:bidding) { create(:bidding, status: :finnished, kind: :global) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal, user: user,
                      user_signed_at: DateTime.current)
  end
end
