module ProposalService
  class Draw::Global

    attr_accessor :bidding, :has_draw

    def initialize(bidding)
      @bidding = bidding
      @has_draw = false
    end

    def self.call(bidding)
      new(bidding).call
    end

    def call
      draw! if draw?
    end

    private

    def draw?
      return false if already_draw? || empty_proposals?

      minimum_draw_proposals?
    end

    def draw!
      ActiveRecord::Base.transaction do
        draw_proposals.map(&:draw!)
        @bidding.draw!
        @has_draw = true

      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      end

      @has_draw
    end

    def minimum_draw_proposals?
      draw_proposals.count > 1
    end

    def draw_proposals
      @draw_proposals ||= proposals.where(price_total: lower_proposal.price_total)
    end

    def lower_proposal
      @lower_proposal ||= proposals.lower
    end

    def proposals
      # only sent proposals
      @proposals ||= @bidding.proposals.sent
    end

    # helpers

    def empty_proposals?
      @bidding.proposals.not_draft_or_abandoned.blank?
    end

    def already_draw?
      @bidding.draw?
    end
  end
end
