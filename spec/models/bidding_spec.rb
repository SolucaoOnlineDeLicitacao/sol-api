require 'rails_helper'

RSpec.describe Bidding, type: :model do
  describe 'factory' do
    let(:factory) { build(:bidding) }

    subject { factory }

    it { is_expected.to be_valid }
  end

  describe 'mount_uploader' do
    it { expect(subject.proposal_import_file).to be_a(FileUploader) }
  end

  describe 'attr_accessor' do
    it { is_expected.to respond_to :skip_cloning_validations }
  end

  describe 'enums' do
    let(:kinds) { { unitary: 1, lot: 2, global: 3 } }
    let(:statuses) do
      {
        draft: 0, waiting: 1, approved: 2, ongoing: 3, draw: 4,
          under_review: 5, finnished: 6, canceled: 7, suspended: 8,
          failure: 9, reopened: 10, desert: 11
      }
    end

    it { is_expected.to define_enum_for(:kind).with_values(kinds) }
    it { is_expected.to define_enum_for(:status).with_values(statuses) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :covenant }
    it { is_expected.to belong_to :classification }
    it { is_expected.to belong_to(:merged_minute_document).class_name(Document).optional }
    it { is_expected.to belong_to(:edict_document).class_name(Document).optional }
    it { is_expected.to belong_to(:spreadsheet_report).class_name(SpreadsheetDocument).optional }
    it { is_expected.to belong_to(:reopen_reason_contract).class_name(Contract).optional }

    it { is_expected.to have_one(:cooperative).through(:covenant) }
    it { is_expected.to have_one(:admin).through(:covenant) }

    it { is_expected.to have_and_belong_to_many(:minute_documents).class_name(Document) }

    it { is_expected.to have_many(:lots).dependent(:destroy) }
    it { is_expected.to have_many(:lot_group_items).through(:lots) }
    it { is_expected.to have_many(:lot_proposals).through(:lots) }
    it { is_expected.to have_many(:proposals).dependent(:destroy) }
    it { is_expected.to have_many(:invites).dependent(:destroy) }
    it { is_expected.to have_many(:providers).through(:invites) }
    it { is_expected.to have_many(:group_items).through(:lot_group_items) }
    it { is_expected.to have_many(:contracts).through(:proposals) }
    it { is_expected.to have_many(:additives).dependent(:destroy) }
    it { is_expected.to have_many(:proposal_imports).dependent(:destroy) }
    it { is_expected.to have_many(:lot_proposal_imports).dependent(:destroy) }
    it { is_expected.to have_many(:event_cancellation_requests).dependent(:destroy) }
    it { is_expected.to have_many(:event_bidding_reproveds).dependent(:destroy) }
    it { is_expected.to have_many(:event_bidding_failures).class_name(Events::BiddingFailure).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :covenant }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_presence_of :modality }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :deadline }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :closing_date }
    it { is_expected.to validate_numericality_of(:deadline).is_greater_than(0).only_integer }

    describe 'validate_fully_failed_lots' do
      context 'when draft' do
        let(:bidding) { build(:bidding, status: :draft) }

        it { expect(bidding).to be_valid }
      end

      context 'when waiting' do
        let(:bidding) { build(:bidding, status: :waiting) }

        it { expect(bidding).to be_valid }
      end

      context 'when approved' do
        let(:bidding) { build(:bidding, status: :approved) }

        it { expect(bidding).to be_valid }
      end

      context 'when ongoing' do
        let(:bidding) { build(:bidding, status: :ongoing) }

        it { expect(bidding).to be_valid }
      end

      context 'when draw' do
        let(:bidding) { build(:bidding, status: :draw) }

        it { expect(bidding).to be_valid }
      end

      context 'when under_review' do
        let(:bidding) { build(:bidding, status: :under_review) }

        it { expect(bidding).to be_valid }
      end

      context 'when finnished' do
        let(:bidding) { build(:bidding, status: :finnished) }

        it { expect(bidding).to be_valid }
      end

      context 'when canceled' do
        let(:bidding) { build(:bidding, status: :canceled) }

        it { expect(bidding).to be_valid }
      end

      context 'when suspended' do
        let(:bidding) { build(:bidding, status: :suspended) }

        it { expect(bidding).to be_valid }
      end

      context 'when failure' do
        let(:bidding) { build(:bidding, status: :failure) }

        describe 'when a lot are failure' do
          before { bidding.lots.map(&:failure!) }

          it { expect(bidding).to be_valid }
        end

        describe 'when a lot arent failure' do
          it { expect(bidding).to be_valid }
        end

        describe 'when a lot arent failure and force failure' do
          before { bidding.force_failure! }

          it { expect(bidding).not_to be_valid }
        end
      end

      context 'when reopened' do
        let(:bidding) { build(:bidding, status: :reopened) }

        it { expect(bidding).to be_valid }
      end

    end

    describe 'lots minimum' do
      context 'when draft' do
        let(:bidding) { build(:bidding, status: :draft) }

        before do
          bidding.lots.destroy_all
          bidding.valid?
        end

        it { expect(bidding).to be_valid }
      end

      context 'when not draft' do
        let(:bidding) { build(:bidding, status: :ongoing) }

        context 'when <= 0' do
          before do
            bidding.lots.destroy_all
            bidding.valid?
          end

          it { expect(bidding).not_to be_valid }
          it { expect(bidding.errors.include?(:lots)).to be_truthy }
        end

        context 'when > 0' do
          it { expect(bidding.lots).to be_present }
          it { expect(bidding).to be_valid }
        end
      end
    end

    describe 'start_date_range' do
      let(:bidding) { build(:bidding, status: :draft) }

      subject { bidding }

      context 'when > closing_date' do
        before do
          bidding.start_date = Date.tomorrow + 1.day
          bidding.closing_date = Date.tomorrow
          bidding.valid?
        end

        it { is_expected.to include_error_key_for(:start_date, :invalid) }
      end

      context 'when <= today' do
        before do
          bidding.start_date = Date.yesterday
          bidding.valid?
        end

        it { is_expected.to include_error_key_for(:start_date, :invalid) }
      end

      context 'when not draft' do
        context 'when <= today' do
          before do
            bidding.waiting!

            bidding.start_date = Date.yesterday
            bidding.valid?
          end

          it { is_expected.not_to include_error_key_for(:start_date, :invalid) }
        end
      end

      context 'when skip_cloning_validations is true' do
        context 'when <= today' do
          before do
            bidding.skip_cloning_validations!

            bidding.start_date = Date.yesterday
            bidding.valid?
          end

          it { is_expected.not_to include_error_key_for(:start_date, :invalid) }
        end
      end
    end

    describe 'closing_date_range' do
      let(:bidding) { build(:bidding, status: :draft) }

      subject { bidding }

      context 'when <= today' do
        before do
          bidding.closing_date = Date.yesterday
          bidding.valid?
        end

        it { is_expected.to include_error_key_for(:closing_date, :invalid) }
      end

      context 'when not draft' do
        context 'when <= today' do
          before do
            bidding.waiting!

            bidding.closing_date = Date.yesterday
            bidding.valid?
          end

          it { is_expected.not_to include_error_key_for(:closing_date, :invalid) }
        end
      end

      context 'when skip_cloning_validations is true' do
        context 'when <= today' do
          before do
            bidding.skip_cloning_validations!

            bidding.closing_date = Date.yesterday
            bidding.valid?
          end

          it { is_expected.not_to include_error_key_for(:closing_date, :invalid) }
        end
      end
    end

    describe 'validate_invites' do
      let(:bidding) { build(:bidding, status: status, modality: modality) }

      before { bidding.valid? }

      subject { bidding }

      context 'when draft' do
        let(:status) { :draft }

        context 'when open_invite' do
          let(:modality) { :open_invite }

          it { is_expected.to be_truthy }
        end

        context 'when closed_invite' do
          let(:modality) { :closed_invite }

          it { is_expected.to be_truthy }
        end

        context 'when unrestricted' do
          let(:modality) { :unrestricted }

          it { is_expected.to be_truthy }
        end
      end

      context 'when not draft' do
        let(:status) { :approved }

        context 'when bidding has no invites' do
          context 'when open_invite' do
            let(:modality) { :open_invite }

            it { is_expected.to include_error_key_for(:invites, :invites_closed_invite) }
          end

          context 'when closed_invite' do
            let(:modality) { :closed_invite }

            it { is_expected.to include_error_key_for(:invites, :invites_closed_invite) }
          end

          context 'when unrestricted' do
            let(:modality) { :unrestricted }

            it { is_expected.to be_truthy }
          end
        end

        context 'when bidding has invites' do
          let(:status) { :approved }
          let!(:invite) { build(:invite, bidding: bidding, status: :approved) }

          context 'when open_invite' do
            let(:modality) { :open_invite }

            it { is_expected.to be_truthy }
          end

          context 'when closed_invite' do
            let(:modality) { :closed_invite }

            it { is_expected.to be_truthy }
          end

          context 'when unrestricted' do
            let(:modality) { :unrestricted }

            it { is_expected.to be_truthy }
          end
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      let(:bidding) { create(:bidding, status: :ongoing) }

      context 'update_draw_at' do
        let(:draw_at_calculated) { bidding.closing_date + bidding.draw_end_days }

        it { expect(bidding.draw_at?).to be_truthy }
        it { expect(bidding.draw_at).to eq draw_at_calculated }
      end
    end

    describe 'before_create' do
      context 'update_position' do
        let!(:covenant_1) { create(:covenant) }
        let!(:biddings_1) { create_list(:bidding, 3, covenant: covenant_1) }

        let!(:covenant_2) { create(:covenant) }
        let!(:biddings_2) { create_list(:bidding, 3, covenant: covenant_2) }

        let(:expected_positions) { [1, 2, 3] }

        context 'when convenant 1 biddings position start from 1' do
          subject { biddings_1.map(&:position) }

          it { is_expected.to eq(expected_positions)}
        end

        context 'when convenant 2 biddings position start from 1' do
          subject { biddings_2.map(&:position) }

          it { is_expected.to eq(expected_positions)}
        end
      end
    end

    describe 'after_create' do
      let(:bidding) { create(:bidding, status: :ongoing) }

      context 'update_title' do
        let(:title) { "#{bidding.id}/#{Date.today.year}" }

        it { expect(bidding.title?).to be_truthy }
        it { expect(bidding.title).to eq title }
      end

      context 'update_code' do
        let(:position_right) { "#{bidding.position}".rjust(3, '0') }
        let(:covenant_number) { bidding.covenant.number.split('/').last }
        let(:year) { Date.current.year.to_s }
        let(:identifier_code) { "#{covenant_number}-#{position_right}-#{year}" }

        it { expect(bidding.code?).to be_truthy }
        it { expect(bidding.code).to eq identifier_code }
      end
    end

    describe 'after_save' do
      describe '.update_estimated_cost_total' do
        let(:biddings) { build_list(:bidding, 2) }
        let(:bidding_1) { biddings.first }
        let(:bidding_2) { biddings.last }
        let!(:lot_1) { create(:lot, bidding: bidding_1) }

        let(:estimated_cost_total_1) { bidding_1.lots.sum(:estimated_cost_total) }
        let(:estimated_cost_total_2) { bidding_2.lots.sum(:estimated_cost_total) }

        before { bidding_1.save; bidding_2.save }

        it { expect(bidding_1.estimated_cost_total).to eq estimated_cost_total_1 }
        it { expect(bidding_2.estimated_cost_total).to eq estimated_cost_total_2 }
      end
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'biddings.created_at' }
    it { expect(described_class.default_sort_direction).to eq :desc }
  end

  describe 'scopes' do
    describe '.not_draft' do
      let!(:approved_bidding) { create(:bidding, status: :approved) }
      let!(:draft_bidding) { create(:bidding, status: :draft) }
      let!(:under_review_bidding) { create(:bidding, status: :under_review) }

      let(:expected_biddings) { [approved_bidding, under_review_bidding] }

      it { expect(Bidding.not_draft).to match_array expected_biddings }
    end

    describe '.approved_and_started_until_today' do
      let!(:bidding1) { create(:bidding, status: :approved, start_date: Date.current) }
      let!(:bidding2) { create(:bidding, status: :approved, start_date: Date.current-1.day) }
      let!(:bidding3) { create(:bidding, status: :approved, start_date: Date.tomorrow) }
      let!(:bidding4) { create(:bidding, status: :canceled) }
      let!(:bidding5) { create(:bidding, status: :under_review) }

      it { expect(Bidding.approved_and_started_until_today).to match_array [bidding1, bidding2] }
    end

    describe '.drawed_until_today' do
      let!(:bidding1) { create(:bidding, status: :draw, closing_date: Date.tomorrow, draw_end_days: 1) }
      let!(:bidding2) { create(:bidding, status: :draw, closing_date: Date.today, draw_end_days: 1) }
      let!(:bidding3) { create(:bidding, status: :draw, closing_date: Date.tomorrow+2.days, draw_end_days: 1) }
      let!(:bidding4) { create(:bidding, status: :waiting) }
      let!(:bidding5) { create(:bidding, status: :approved) }

      let(:date_current) { bidding1.closing_date + bidding1.draw_end_days.to_i }

      before { allow(Date).to receive(:current).and_return date_current }

      it { expect(Bidding.drawed_until_today).to match_array [bidding1, bidding2] }
    end

    describe '.ongoing_and_closed_until_today' do
      let!(:bidding1) { create(:bidding, status: :ongoing, closing_date: Date.current-1.day) }
      let!(:bidding2) { create(:bidding, status: :ongoing, closing_date: Date.current) }
      let!(:bidding3) { create(:bidding, status: :ongoing, closing_date: Date.tomorrow) }
      let!(:bidding4) { create(:bidding, status: :waiting) }
      let!(:bidding5) { create(:bidding, status: :approved) }

      it { expect(Bidding.ongoing_and_closed_until_today).to match_array [bidding2, bidding1] }
    end

    describe 'in_progress' do
      let(:covenant) { create(:covenant) }
      let(:bidding_1) { create(:bidding, covenant: covenant, status: :ongoing) }
      let(:bidding_2) { create(:bidding, covenant: covenant, status: :approved) }
      let(:bidding_3) { create(:bidding, covenant: covenant, status: :failure) }
      let(:bidding_4) { create(:bidding, covenant: covenant, status: :draw) }
      let(:bidding_5) { create(:bidding, covenant: covenant, status: :canceled) }

      subject { covenant.biddings.in_progress }

      it { is_expected.to match_array [bidding_1, bidding_2] }
    end

    describe 'ids_without_contracts' do
      let(:user) { create(:user) }
      let(:covenant) { create(:covenant) }
      let(:bidding_1) { create(:bidding, covenant: covenant, status: :ongoing) }
      let(:provider) { create(:provider) }
      let(:bidding_2) { create(:bidding, status: 6, kind: 3) }
      let(:proposal) { create(:proposal, bidding: bidding_2, provider: provider, status: :accepted) }
      let!(:contract) do
        create(:contract, proposal: proposal, user: user,
                          user_signed_at: DateTime.current)
      end

      let(:bidding_1_ids_without_contracts) { Bidding.ids_without_contracts(bidding_1.id) }
      let(:bidding_2_ids_without_contracts) { Bidding.ids_without_contracts(bidding_2.id) }

      it { expect(bidding_1_ids_without_contracts).to eq [bidding_1.id] }
      it { expect(bidding_2_ids_without_contracts).to eq [] }
    end
  end

  describe 'methods' do
    describe '.by_provider' do
      let!(:provider) { create(:provider) }

      let!(:draft_bidding) { create(:bidding, status: :draft) }

      let!(:unrestricted_ongoing_bidding) do
        create(:bidding, status: :ongoing, modality: :unrestricted)
      end

      let!(:open_invite_approved_bidding) do
        create(:bidding, status: :approved, modality: :open_invite, build_invite: true)
      end

      let!(:open_invite_ongoing_bidding) do
        create(:bidding, status: :ongoing, modality: :open_invite, build_invite: true)
      end

      let!(:closed_invite_ongoing_bidding) do
        create(:bidding, status: :ongoing, modality: :closed_invite, build_invite: true)
      end

      let!(:closed_invite_ongoing_bidding_invite_approved) do
        create(:bidding, status: :ongoing, modality: :closed_invite, build_invite: true)
      end

      let!(:approved_invite) do
        create(:invite, bidding: closed_invite_ongoing_bidding_invite_approved,
          provider: provider, status: :approved)
      end

      let!(:pending_invite) do
        create(:invite, bidding: closed_invite_ongoing_bidding,
          provider: provider, status: :pending)
      end

      let(:expected) do
        [
          unrestricted_ongoing_bidding, open_invite_ongoing_bidding,
          closed_invite_ongoing_bidding_invite_approved
        ]
      end

      it { expect(Bidding.by_provider(provider)).to match_array expected }
    end

    describe 'self.active' do
      let(:bidding) { create(:bidding, status: 3) }

      before do
        create(:bidding, status: 0)
        create(:bidding, status: 1)
        create(:bidding, status: 2)
      end

      it { expect(Bidding.active).to eq [bidding] }
    end

    describe 'self.in_progress_count' do
      before do
        create(:bidding, status: :ongoing)
        create(:bidding, status: :ongoing)
        create(:bidding, status: :draw)
        create(:bidding, status: :draw)
        create(:bidding, status: :draw)
        create(:bidding, status: :under_review)
        create(:bidding, status: :under_review)
        create(:bidding, status: :approved)
        create(:bidding, status: :canceled)
        create(:bidding, status: :finnished)
      end

      it { expect(Bidding.in_progress_count).to eq 7 }
    end

    describe 'proposals_for_retry_by_lot' do
      let!(:bidding) { create(:bidding, status: :waiting, kind: kind) }

      subject { bidding.proposals_for_retry_by_lot(scope_params) }

      context 'when the bidding kind is lot' do
        let(:kind) { :lot }
        let(:lot_1) { bidding.lots.first }
        let(:lot_2) { create(:lot, bidding: bidding) }
        let!(:proposal_1) { create(:proposal, bidding: bidding, lot: lot_1, status: :draw) }
        let!(:proposal_2) { create(:proposal, bidding: bidding, lot: lot_1, status: :sent) }
        let!(:proposal_3) { create(:proposal, bidding: bidding, lot: lot_1, status: :accepted) }
        let!(:proposal_4) { create(:proposal, bidding: bidding, lot: lot_1, status: :refused) }
        let!(:proposal_5) { create(:proposal, bidding: bidding, lot: lot_2, status: :sent) }
        let(:scope_params) { proposal_1.current_lot_ids }

        it { is_expected.to match_array [proposal_2, proposal_3, proposal_4] }
      end

      context 'when the bidding kind is global' do
        let(:kind) { :global }
        let!(:proposal_1) { create(:proposal, bidding: bidding, status: :draw) }
        let!(:proposal_2) { create(:proposal, bidding: bidding, status: :sent) }
        let!(:proposal_3) { create(:proposal, bidding: bidding, status: :accepted) }
        let!(:proposal_4) { create(:proposal, bidding: bidding, status: :refused) }
        let!(:proposal_5) { create(:proposal, bidding: bidding, status: :sent) }
        let(:scope_params) { bidding.lot_ids }

        it { is_expected.to match_array [proposal_2, proposal_3, proposal_4, proposal_5] }
      end
    end

    describe 'proposals_not_draft_or_abandoned' do
      let!(:bidding) { create(:bidding, kind: kind) }

      context 'when bidding is lot kind' do
        let!(:kind) { :lot }
        let!(:lot_1) { bidding.lots.first }
        let!(:lot_2) { create(:lot, bidding: bidding) }
        let!(:lot_3) { create(:lot, bidding: bidding) }
        let!(:proposal_a_lot_1) do
          create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5001,
            sent_updated_at: DateTime.now)
        end

        let!(:proposal_b_lot_1) do
          create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5000,
            sent_updated_at: DateTime.now+1.day)
        end

        it { expect(bidding.proposals_not_draft_or_abandoned.size).to eq 2 }
      end

      context 'when bidding is global kind' do
        let!(:kind) { :global }
        let!(:proposal_a_lot_1) do
          create(:proposal, bidding: bidding, status: :sent, price_total: 5001,
            sent_updated_at: DateTime.now)
        end
        let!(:proposal_b_lot_1) do
          create(:proposal, bidding: bidding, status: :sent, price_total: 5000,
            sent_updated_at: DateTime.now+1.day)
        end
        let!(:proposal_c_lot_1) do
          create(:proposal, bidding: bidding, status: :sent, price_total: 5003,
            sent_updated_at: DateTime.now+3.day)
        end

        it { expect(bidding.proposals_not_draft_or_abandoned.size).to eq 3 }
      end
    end

    describe '.fully_failed_lots?' do
      let!(:bidding) { create(:bidding) }

      context 'when return true' do
        let!(:lot_1) { bidding.lots.first }
        let!(:lot_2) { create(:lot, bidding: bidding) }
        let!(:lot_3) { create(:lot, bidding: bidding) }

        before { lot_1.failure!; lot_2.failure!; lot_3.failure!; }

        it { expect(bidding.reload.fully_failed_lots?).to be_truthy }
      end

      context 'when return false' do
        let!(:lot_4) { bidding.lots.first }
        let!(:lot_5) { create(:lot, bidding: bidding) }
        let!(:lot_6) { create(:lot, bidding: bidding) }

        before { lot_4.failure! }

        it { expect(bidding.reload.fully_failed_lots?).to be_falsey }
      end
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
