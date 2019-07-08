require 'rails_helper'

RSpec.describe Events::ContractRefused, type: :model do
  subject(:event_contract_refused) { build(:event_contract_refused) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'validation' do
    let(:contract_statuses) { %w(refused) }

    context 'to' do
      it { is_expected.to validate_inclusion_of(:to).in_array(contract_statuses) }
      it { is_expected.to define_data_attr(:to) }
    end

    it { is_expected.to define_data_attr(:comment) }
  end
end
