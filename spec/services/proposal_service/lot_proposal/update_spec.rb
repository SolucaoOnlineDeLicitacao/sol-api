require 'rails_helper'

RSpec.describe ProposalService::LotProposal::Update, type: :service do
  describe '.call' do
    let(:response) { double('api_response', success?: blockchain_response) }
    let(:blockchain_response) { true }
    let(:proposal) { create(:proposal, build_lot_proposal: false) }
    let(:lot_proposal) { create(:lot_proposal, proposal: proposal) }
    let(:params) { { delivery_price: 100 } }

    before do
      allow(Blockchain::Proposal::Update).
        to receive(:call).with(proposal).and_return(response)
    end

    subject { described_class.call(lot_proposal: lot_proposal, params: params) }

    context 'when it runs successfully' do
      context 'and the lot proposal is successfully updated' do
        let(:bidding) { proposal.bidding }

        describe "delivery_price" do
          before { bidding.ongoing!; subject }

          it { is_expected.to be_truthy }
          it { expect(lot_proposal.reload.delivery_price).to eq 100 }
        end

        describe "blockchain" do
          before { bidding.ongoing! }

          context "when proposal is draft" do
            before { subject }

            it { is_expected.to be_truthy }
            it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
          end

          context "when proposal isnt draft" do
            before { proposal.update_attribute(:status, :sent); proposal.reload; subject }

            it { is_expected.to be_truthy }
            it { expect(Blockchain::Proposal::Update).to have_received(:call).with(proposal) }
          end
        end
      end
    end

    context 'when it runs with failures' do
      context 'and the lot proposal is invalid' do
        let(:params) { { delivery_price: -10 } }

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { lot_proposal.reload.delivery_price } }
      end

      context 'and bidding is under_review' do
        let(:bidding) { proposal.bidding }
        let(:can_not_edit_message) { I18n.t('activerecord.errors.models.proposal.attributes.bidding.can_not_edit') }

        before { bidding.under_review!; subject }

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { lot_proposal.reload.delivery_price } }
        it { expect(proposal.errors[:bidding]).to eq [can_not_edit_message] }
      end

      context 'and bidding is draw and proposal is accepted' do
        let(:bidding) { proposal.bidding }
        let(:can_not_edit_message) { I18n.t('activerecord.errors.models.proposal.attributes.bidding.can_not_edit') }

        before do
          bidding.draw!
          proposal.status = :accepted
          proposal.save(validate: false)
          subject
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { lot_proposal.reload.delivery_price } }
        it { expect(proposal.errors[:bidding]).to eq [can_not_edit_message] }
      end

      context 'and the blockchain call has errors' do
        let(:blockchain_response) { false }

        before { subject }

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { lot_proposal.reload.delivery_price } }
      end

    end
  end
end
