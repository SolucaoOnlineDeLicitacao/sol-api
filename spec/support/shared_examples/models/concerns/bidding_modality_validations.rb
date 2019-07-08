require 'spec_helper'

shared_examples_for "bidding_modality_validations" do
  let(:user) { create(:supplier) }
  let(:provider) { create(:provider, type: 'Provider') }
  let!(:lots) { create_list(:lot, 2) }
  let(:invite) { create(:invite, status: :approved) }
  let!(:bidding) do
    create(:bidding, build_invite: true, build_lot: false, kind: kind,
                     modality: modality, lots: lots, invites: [invite])
  end
  let!(:lot_proposal) { create(:lot_proposal, lot: lots.first) }
  let!(:proposal) do
    create(:proposal, build_lot_proposal: false, bidding: bidding,
                      lot_proposals: [lot_proposal], provider: provider,
                      status: first_proposal_status)
  end

  context 'when creating' do
    let(:first_proposal_status) { :abandoned }
    let!(:second_lot_proposal) { create(:lot_proposal, lot: lots.last) }
    let(:error) do
      'A validação falhou: Bidding já existe uma' \
      ' proposta abandonada para esta licitação'
    end

    subject do
      create(:proposal, build_lot_proposal: false, bidding: bidding,
                        lot_proposals: [second_lot_proposal],
                        provider: provider, status: :sent)
    end

    context 'and the bidding modality is closed_invite' do
      let(:modality) { :closed_invite }

      context 'and the bidding kind is global' do
        let(:kind) { :global }

        context 'and the second proposal has the same provider and bidding' do
          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end

        context 'and the second proposal has the same provider and another bidding' do
          let(:invite) { create(:invite, status: :approved) }
          let!(:another_bidding) do
            create(:bidding, build_invite: true, build_lot: false, kind: kind,
                             modality: modality, lots: lots, invites: [invite])
          end

          subject do
            create(:proposal, build_lot_proposal: false,
                              bidding: another_bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end

        context 'and the second proposal has another provider and same bidding' do
          let(:another_provider) { create(:provider, type: 'Provider') }

          subject do
            create(:proposal, build_lot_proposal: false, bidding: bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: another_provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end
      end
      context 'and the bidding kind is lot' do
        let(:kind) { :lot }

        context 'and the second proposal has the same provider and bidding' do
          it { is_expected.to be_truthy }
        end

        context 'and trying to create another proposal for first lot' do
          subject do
            create(:proposal, build_lot_proposal: false, bidding: bidding,
                              lot_proposals: [lot_proposal],
                              provider: provider, status: :sent)
          end

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end

        context 'and the second proposal has the same provider and another bidding' do
          let(:invite) { create(:invite, status: :approved) }
          let!(:another_bidding) do
            create(:bidding, build_invite: true, build_lot: false, kind: kind,
                             modality: modality, lots: lots, invites: [invite])
          end

          subject do
            create(:proposal, build_lot_proposal: false,
                              bidding: another_bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end

        context 'and the second proposal has another provider and same bidding' do
          let(:another_provider) { create(:provider, type: 'Provider') }

          subject do
            create(:proposal, build_lot_proposal: false, bidding: bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: another_provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end
      end
    end
    context 'when open_invite' do
      let(:modality) { :open_invite }

      context 'and the bidding kind is global' do
        let(:kind) { :global }

        context 'and the second proposal has the same provider and bidding' do
          it { is_expected.to be_truthy }
        end

        context 'and the second proposal has the same provider and another bidding' do
          let!(:another_bidding) do
            create(:bidding, build_invite: true, build_lot: false, kind: kind,
                             modality: modality, lots: lots)
          end

          subject do
            create(:proposal, build_lot_proposal: false,
                              bidding: another_bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end

        context 'and the second proposal has another provider and same bidding' do
          let(:another_provider) { create(:provider, type: 'Provider') }

          subject do
            create(:proposal, build_lot_proposal: false, bidding: bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: another_provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end
      end
      context 'and the bidding kind is lot' do
        let(:kind) { :lot }

        context 'and the second proposal has the same provider and bidding' do
          it { is_expected.to be_truthy }
        end

        context 'and the second proposal has the same provider and another bidding' do
          let!(:another_bidding) do
            create(:bidding, build_invite: true, build_lot: false, kind: kind,
                             modality: modality, lots: lots)
          end

          subject do
            create(:proposal, build_lot_proposal: false,
                              bidding: another_bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end

        context 'and the second proposal has another provider and same bidding' do
          let(:another_provider) { create(:provider, type: 'Provider') }

          subject do
            create(:proposal, build_lot_proposal: false, bidding: bidding,
                              lot_proposals: [second_lot_proposal],
                              provider: another_provider, status: :sent)
          end

          it { is_expected.to be_truthy }
        end
      end
    end
  end

  context 'when updating' do
    let(:error) do
      'A validação falhou: Bidding não pode alterar a'\
      ' proposta pois a licitação é de convite fechado'
    end

    subject { proposal.update!(params) }

    context 'and the bidding modality is closed_invite' do
      let(:modality) { :closed_invite }

      context 'and the bidding kind is global' do
        let(:kind) { :global }

        context 'and changing the proposal price when is draw' do
          let(:first_proposal_status) { :draw }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end

        context 'and changing the proposal status from draw to sent' do
          let(:first_proposal_status) { :draw }
          let(:params) { { status: :sent } }

          it { is_expected.to be_truthy }
        end

        context 'and changing the proposal status from draw to abandoned' do
          let(:first_proposal_status) { :draw }
          let(:params) { { status: :abandoned } }

          it { is_expected.to be_truthy }
        end

        context 'and changing the proposal status from draft to abandoned' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :abandoned } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from draft to sent' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :sent } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal price when is draft' do
          let(:first_proposal_status) { :draft }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from abandoned to draft' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { status: :draft } }

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end
        context 'and changing the proposal price when is abandoned' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { price_total: 100 } }

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end
        context 'and changing the proposal price when is sent' do
          let(:first_proposal_status) { :sent }
          let(:params) { { price_total: 100 } }

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end
      end
      context 'and the bidding kind is lot' do
        let(:kind) { :lot }

        context 'and changing the proposal price when is draw' do
          let(:first_proposal_status) { :draw }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end

        context 'and changing the proposal status from draft to abandoned' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :abandoned } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from draft to sent' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :sent } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal price when is draft' do
          let(:first_proposal_status) { :draft }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from abandoned to draft' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { status: :draft } }

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end
        context 'and changing the proposal price when is abandoned' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { price_total: 100 } }

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end
        context 'and changing the proposal price when is sent' do
          let(:first_proposal_status) { :sent }
          let(:params) { { price_total: 100 } }

          it do
            expect { subject }.
              to raise_error(ActiveRecord::RecordInvalid, error)
          end
        end
      end
    end
    context 'when open_invite' do
      let(:modality) { :open_invite }

      context 'and the bidding kind is global' do
        let(:kind) { :global }

        context 'and changing the proposal price when is draw' do
          let(:first_proposal_status) { :draw }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end

        context 'and changing the proposal status from draft to abandoned' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :abandoned } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from draft to accepted' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :accepted } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from abandoned to accepted' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { status: :accepted } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal price when is draft' do
          let(:first_proposal_status) { :draft }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal price when is abandoned' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end
      end
      context 'and the bidding kind is lot' do
        let(:kind) { :lot }

        context 'and changing the proposal price when is draw' do
          let(:first_proposal_status) { :draw }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end

        context 'and changing the proposal status from draft to abandoned' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :abandoned } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from draft to accepted' do
          let(:first_proposal_status) { :draft }
          let(:params) { { status: :accepted } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal status from abandoned to accepted' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { status: :accepted } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal price when is draft' do
          let(:first_proposal_status) { :draft }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end
        context 'and changing the proposal price when is abandoned' do
          let(:first_proposal_status) { :abandoned }
          let(:params) { { price_total: 100 } }

          it { is_expected.to be_truthy }
        end
      end
    end
  end
end
