module ProposalService
  class Draw
    attr_accessor :bidding, :has_draw

    def initialize(bidding)
      @bidding = bidding
      @has_draw = false
    end

    def self.call(bidding)
      new(bidding).call
    end

    def call
      resolve_draw! unless draw_or_empty?
    end

    private

    def resolve_draw!
      if global?
        @has_draw = ProposalService::Draw::Global.call(@bidding)
      else
        draw!
      end
    end

    def draw!
      ActiveRecord::Base.transaction do
        @bidding.lots.find_each do |lot|
          # only sent proposals
          proposals = lot.proposals.sent
          lower_proposal = proposals.lower

          # when desert we just go to next
          next unless lower_proposal.present?

          lower_proposals = proposals.where(price_total: lower_proposal.price_total)

          if lower_proposals.count > 1
            lower_proposals.map(&:draw!)

            @bidding.draw! unless already_draw?
            @has_draw = true
          end
        end

      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      end
    end

    def global?
      @bidding.global?
    end

    def draw_or_empty?
      already_draw? || empty_proposals?
    end

    def empty_proposals?
      @bidding.proposals.not_draft_or_abandoned.blank?
    end

    def already_draw?
      @bidding.draw?
    end
  end
end
