RSpec.shared_examples "imports_running with" do |resource|
  let(:provider) { create(:provider, type: 'Provider') }
  let(:bidding) { create(:bidding) }
  let(:error) { 'já existe uma proposta sendo importada para esta licitação' }

  context 'when a proposal has already been imported' do
    let!(resource) do
      create(resource, bidding: bidding, provider: provider, status: :success)
    end
    let(:proposal) { build(:proposal, bidding: bidding, provider: provider) }

    subject { proposal.valid? }

    it { is_expected.to be_truthy }
  end

  context 'when there is already a proposal being imported' do
    let!(resource) do
      create(resource, bidding: bidding, provider: provider, status: :processing)
    end

    context 'and is creating a new proposal' do
      subject { new_proposal.valid? }

      context 'and the same bidding and provider' do
        context 'and the importer is not running' do
          let(:new_proposal) do
            build(:proposal, bidding: bidding, provider: provider)
          end

          it { is_expected.to be_falsey }

          describe 'and the error' do
            before { subject }

            it { expect(new_proposal.errors.messages[:bidding].first).to eq(error) }
          end
        end
        context 'and the importer is running' do
          let(:new_proposal) do
            build(:proposal, bidding: bidding,
                             provider: provider,
                             import_creating: true)
          end

          it { is_expected.to be_truthy }
        end
      end
      context 'and the same bidding and the another provider' do
        let(:another_provider) { create(:provider, type: 'Provider') }
        let(:new_proposal) do
          build(:proposal, bidding: bidding, provider: another_provider)
        end

        it { is_expected.to be_truthy }
      end
      context 'and the another bidding and same provider' do
        let(:another_bidding) { create(:bidding) }
        let(:new_proposal) do
          build(:proposal, bidding: another_bidding, provider: provider)
        end

        it { is_expected.to be_truthy }
      end
      context 'and the another bidding and provider' do
        let(:another_provider) { create(:provider, type: 'Provider') }
        let(:another_bidding) { create(:bidding) }
        let(:new_proposal) do
          build(:proposal, bidding: another_bidding, provider: another_provider)
        end

        it { is_expected.to be_truthy }
      end
    end
  end

  context 'when is other operations' do
    let(resource) do
      create(resource, bidding: bidding, provider: provider, status: :success)
    end
    let(:proposal) { build(:proposal, bidding: bidding, provider: provider) }

    before do
      proposal.save!
      send(resource).update!(status: :processing)
    end

    context 'and is updating the proposal' do
      before { proposal.update(price_total: 100) }

      subject { proposal.valid? }

      it { is_expected.to be_falsey }
      it { expect(proposal.errors.messages[:bidding].first).to eq(error) }
    end

    context 'and is destroying the proposal' do
      subject { proposal.destroy }

      it { is_expected.to be_falsey }
      it { expect { subject }.not_to change(Proposal, :count) }

      describe 'and validating the error message' do
        before { proposal.valid? }

        it { expect(proposal.errors.messages[:bidding].first).to eq(error) }
      end
    end
  end
end
