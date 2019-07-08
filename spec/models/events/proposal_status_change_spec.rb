require 'rails_helper'

RSpec.describe Events::ProposalStatusChange, type: :model do
  subject(:event_proposal_status_change) { build(:event_proposal_status_change) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'validation' do
    let(:proposal_statuses) { Proposal.statuses.keys }

    context 'to' do
      it { is_expected.to validate_inclusion_of(:to).in_array(proposal_statuses) }
      it { is_expected.to define_data_attr(:to) }
    end

    context 'from' do
      it { is_expected.to validate_inclusion_of(:from).in_array(proposal_statuses) }
      it { is_expected.to define_data_attr(:from) }
    end

    it { is_expected.to define_data_attr(:comment) }
  end

  context 'scopes' do
    describe '.changing_to(status)' do
      it 'filters events registering status changes to status argument' do
        matching_events = create_list :event_proposal_status_change, 2, from: 'triage', to: 'coop_refused'
        non_matching_events = create_list :event_proposal_status_change, 2, from: 'triage', to: 'coop_accepted'

        expect(Events::ProposalStatusChange.changing_to('coop_refused')).to match_array matching_events
      end
    end
  end
end
