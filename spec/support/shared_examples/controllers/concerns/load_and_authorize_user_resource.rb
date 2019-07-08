RSpec.shared_examples 'an user authorization to' do |operation|
  before { subject }

  describe "#{operation}" do
    it { expect(response).to be_present }
  end
end
