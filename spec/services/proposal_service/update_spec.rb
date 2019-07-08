require 'rails_helper'

RSpec.describe ProposalService::Update, type: :service do
  let(:proposal) { create(:proposal) }
  let(:bidding) { proposal.bidding }
  let(:proposal_params) { { price_total: 123 } }
  let(:params) { { proposal: proposal, params: proposal_params } }

  describe '#initialize' do
    subject { described_class.new(params) }

    context 'when bidding is draw' do
      before { bidding.draw! }

      it { expect(subject.proposal).to eq(proposal) }
      it { expect(subject.params.keys).to match_array %i[price_total sent_updated_at] }
    end

    context 'when bidding is not draw' do
      it { expect(subject.proposal).to eq(proposal) }
      it { expect(subject.params.keys).to match_array %i[price_total sent_updated_at status] }
    end
  end

  with_versioning do
    describe '.call' do
      let(:response) { double('api_response', success?: blockchain_response) }
      let(:blockchain_response) { true }
      let(:current_datetime) { DateTime.new(2019,1,1,10,0,0) }

      before do
        allow(DateTime).to receive(:current).and_return(current_datetime)
        allow(Blockchain::Proposal::Create).
          to receive(:call).with(proposal).and_return(response)
        allow(Blockchain::Proposal::Update).
          to receive(:call).with(proposal).and_return(response)
      end

      subject { described_class.call(params) }

      context 'when it runs successfully' do
        before { bidding.ongoing! }

        context 'and the lot proposal is successfully updated' do
          context 'and the proposal status does not come from draft' do
            before { proposal.accepted! }

            it { is_expected.to be_truthy }
            it { expect { subject }.to change { proposal.reload.status }.from('accepted').to('sent') }
            it { expect { subject }.to change { proposal.reload.sent_updated_at }.to(current_datetime) }

            describe 'and validating blockchain call' do
              before { subject }

               it { expect(Blockchain::Proposal::Create).not_to have_received(:call).with(proposal) }
               it { expect(Blockchain::Proposal::Update).to have_received(:call).with(proposal) }
            end
          end

          context 'and the proposal status comes from draft' do
            it { is_expected.to be_truthy }
            it { expect { subject }.to change { proposal.reload.status }.from('draft').to('sent') }
            it { expect { subject }.to change { proposal.reload.sent_updated_at }.to(current_datetime) }

            describe 'and validating blockchain call' do
              before { subject }

               it { expect(Blockchain::Proposal::Create).to have_received(:call).with(proposal) }
               it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
            end
          end
        end
      end

      context 'when it runs with failures' do
        context 'and the proposal is invalid' do
          let(:proposal_params) { { status: nil } }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.status } }
        end

        context 'and the blockchain call has errors' do
          let(:blockchain_response) { false }

          before { bidding.ongoing! }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.sent_updated_at } }
        end

        context 'and bidding is under_review' do
          let(:can_not_edit_message) { I18n.t('activerecord.errors.models.proposal.attributes.bidding.can_not_edit') }

          before { bidding.under_review!; subject }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.status } }
          it { expect(proposal.errors[:bidding]).to eq [can_not_edit_message] }
        end

        context 'and bidding is draw and proposal is accepted' do
          let(:can_not_edit_message) { I18n.t('activerecord.errors.models.proposal.attributes.bidding.can_not_edit') }

          before do
            bidding.draw!
            proposal.status = :accepted
            proposal.save(validate: false)
            subject
          end

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.status } }
          it { expect(proposal.errors[:bidding]).to eq [can_not_edit_message] }
        end
      end
    end
  end
end
