RSpec.shared_examples "concerns/notifiable" do

  describe 'associations' do
    it { is_expected.to have_many(:notifications) }
  end
end
