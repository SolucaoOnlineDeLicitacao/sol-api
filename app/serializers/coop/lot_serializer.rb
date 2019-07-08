module Coop
  class LotSerializer < ActiveModel::Serializer
    attributes :id, :name, :title, :deadline, :address, :bidding_id, :bidding_title, :bidding_kind,
            :bidding_modality, :bidding_status, :status, :lot_group_items_count,
            :lot_proposals_count, :bidding_proposals_count, :position, :estimated_cost_total

    has_many :lot_group_items, serializer: Coop::LotGroupItemSerializer
    has_many :attachments, serializer: AttachmentSerializer

    def title
      "#{object.position} - #{object.name}"
    end

    def bidding_title
      bidding.title
    end

    def bidding_status
      bidding.status
    end

    def bidding_kind
      bidding.kind
    end

    def bidding_modality
      bidding.modality
    end

    def bidding_proposals_count
      bidding.proposals.not_draft.count
    end

    def lot_proposals_count
      object.lot_proposals.count
    end

    private

    def bidding
      object.bidding
    end
  end
end
