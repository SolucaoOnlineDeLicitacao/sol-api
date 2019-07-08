RSpec.shared_examples 'a scope to' do
  let(:current_ability) { Abilities::Strategy.call(user: user) }

  before do
    allow(controller).to receive(:current_ability).and_return(current_ability)
    allow(resource).to receive(:accessible_by).and_return(resource.all)

    get_index
  end

  it { expect(resource).to have_received(:accessible_by).with(current_ability) }
end
