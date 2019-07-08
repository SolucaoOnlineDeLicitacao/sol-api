require 'rails_helper'

RSpec.describe EventServices::Contract::Refused, type: :service do
  include_examples 'services/concerns/init_contract'

  let(:comment) { 'comment' }
  let(:refused_by) { supplier }
  let(:event_params) { { contract: contract, comment: comment, user: refused_by } } 

  subject(:service) do
    described_class.new(event_params)
  end

  let(:event) do
    build(:event_contract_refused, eventable: contract, creator: refused_by,
      comment: comment, from: contract.status, to: 'refused')
  end

  before { contract.refused! } 

  describe '#initialize' do
    it { expect(service.contract).to eq contract }
    it { expect(service.comment).to eq comment }
    it { expect(service.user).to eq refused_by }
    it { expect(service.event).to be_a_new Events::ContractRefused }
    it { expect(service.event.attributes).to eq event.attributes }
  end

  describe 'call' do
    context 'when success' do
      before { service.call }
        
      it { expect(service.event).to be_persisted }
    end

    context 'when failure' do
      let(:error_event_key) { [:comment] } 
      before do
        event_params.delete(:comment)
        
        service.call
      end

      it { expect(service.event).not_to be_persisted }
      it { expect(service.event.errors.messages.keys).to eq error_event_key }
    end
  end
end
