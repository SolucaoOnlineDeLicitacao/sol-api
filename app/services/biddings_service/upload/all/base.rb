module BiddingsService::Upload::All
  class Base
    attr_accessor :user, :import, :bidding, :lot_proposals, :proposal

    BIDDING_COLUMN = :first
    LOT_COLUMN = :second
    FROM_LINE_THREE = 2
    TO_END = -1

    def initialize(args)
      @user = args[:user]
      @import = args[:import]
      @bidding = nil
      @lot_proposals = []
      @proposal = nil
    end

    def self.call!(args)
      new(args).call!
    end

    def call!
      read_spreadsheet_and_persist_data!
    end

    private

    def read_spreadsheet_and_persist_data!
      active_record_rollback = false

      ActiveRecord::Base.transaction do
        iterate_and_update_or_create_proposal!

      rescue => error
        active_record_rollback = true
        raise ActiveRecord::Rollback
      end

      raise_error if active_record_rollback
    rescue => error
      raise error
    end

    def iterate_and_update_or_create_proposal!
      all_rows.group_by(&BIDDING_COLUMN).each do |row_bidding_id, lots_rows|
        raise_error if from_another_bidding?(row_bidding_id)
        define_bidding_with(row_bidding_id)
        iterate_and_fill_lot_proposals(lots_rows)
      end

      update_or_create_proposal!
    end

    def iterate_and_fill_lot_proposals(lots_rows)
      lots_rows.group_by(&LOT_COLUMN).each do |row_lot_id, lines|
        lot = bidding_lots_by(row_lot_id)
        lot_proposal = update_or_build_lot_proposal(lot)

        lines.each do |line|
          lot_proposal.lot_group_item_lot_proposals.push(
            update_or_build_lot_group_item_lot_proposal(line, lot)
          )
        end

        lot_proposals << lot_proposal
      end
    end

    def from_another_bidding?(row_bidding_id)
      import.bidding_id != row_bidding_id
    end

    def update_or_build_lot_proposal(lot)
      delivery_price = row_delivery_price.call(lot: lot, sheet: lot_sheet)

      result = lot_proposal(lot.id)

      return update_delivery_price(result, delivery_price) if result.present?

      LotProposal.new(lot: lot, delivery_price: delivery_price)
    end

    def update_or_build_lot_group_item_lot_proposal(line, lot)
      row = row_values.new(line)

      result = lot_group_item_lot_proposal(lot.id, row.lot_group_item_id)

      return update_price_and_define_proposal(result, row.price) if result.present?

      lot_group_item = lot_group_items_by(lot, row.lot_group_item_id)
      LotGroupItemLotProposal.new(
        lot_group_item: lot_group_item, price: row.price, import_creating: true
      )
    end

    def update_delivery_price(lot_proposal, delivery_price)
      lot_proposal.update!(delivery_price: delivery_price) if delivery_price.present?
      lot_proposal
    end

    def update_price_and_define_proposal(lot_group_item_lot_proposal, price)
      lot_group_item_lot_proposal.update!(price: price, import_creating: true)

      proposal_id = lot_group_item_lot_proposal.proposal.id
      @proposal = Proposal.find(proposal_id)

      lot_group_item_lot_proposal
    end

    def lot_proposal(lot_id)
      LotProposal.
        joins(:proposal, :provider).
        where(
          proposals: { bidding_id: bidding.id },
          lot_id: lot_id,
          providers: { id: provider.id }
        ).last
    end

    def lot_group_item_lot_proposal(lot_id, lot_group_item_id)
      LotGroupItemLotProposal.
        joins(:proposal, :lot_proposal, :lot_group_item, :provider).
        where(
          proposals: { bidding_id: bidding.id },
          lot_proposals: { lot_id: lot_id},
          lot_group_items: { id: lot_group_item_id },
          providers: { id: provider.id }
        ).last
    end

    def update_or_create_proposal!
      return if bidding.blank?

      return proposal.update!(proposal_update_params) if proposal.present?

      validate_proposal_items_quantity

      ProposalService::Create.call!(proposal_create_params)
    end

    def proposal_update_params
      { lot_proposals: lot_proposals, import_creating: true }
    end

    def proposal_create_params
      {
        proposal: build_proposal,
        user: user,
        provider: provider,
        bidding: bidding,
        status: :draft
      }
    end

    def build_proposal
      @build_proposal ||= Proposal.new(lot_proposals: lot_proposals, import_creating: true)
    end

    def define_bidding_with(row_bidding_id)
      @bidding = Bidding.find_by(id: row_bidding_id)

      raise_error if bidding.blank?
    end

    def bidding_lots_by(row_lot_id)
      lot = bidding.lots.find_by(id: row_lot_id)
      raise_error if lot.blank?
      lot
    end

    def lot_group_items_by(lot, lot_group_item_id)
      lot_group_item = lot.lot_group_items.find_by(id: lot_group_item_id)
      raise_error if lot_group_item.blank?
      lot_group_item
    end

    def validate_proposal_items_quantity
      build_proposal.lot_proposals.each do |lot_proposal|
        raise_error if invalid_items_quantity?(lot_proposal)
      end
    end

    def invalid_items_quantity?(lot_proposal)
      lot_proposal.lot.lot_group_items_count != lot_proposal.lot_group_item_lot_proposals.size
    end

    def provider
      @provider ||= user.provider
    end

    def raise_error
      raise ActiveRecord::RecordInvalid
    end
  end
end
