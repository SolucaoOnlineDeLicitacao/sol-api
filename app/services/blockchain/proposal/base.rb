require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class Base
      attr_accessor :proposal

      ENDPOINT = "/api/Proposal"

      def self.call(proposal)
        new(proposal).call
      end

      def initialize(proposal)
        @proposal = proposal
        @client = ApiBlockchain::Client.new
      end

      def call
        raise NotImplementedError
      end

      private

      def params
        {
          '$class': 'sdc.network.Proposal',
          'proposalId': proposal.id,
          'biddingId': proposal.bidding_id,
          'bidding': "resource:sdc.network.Bidding##{proposal.bidding_id}",
          'providerId': proposal.provider_id,
          'price_total': proposal.price_total.to_f,
          'status': proposal.status.upcase,
          "sent_update_at": proposal.sent_updated_at,
          'lot_proposals': lots_params
        }
      end

      def lots_params
        proposal.lot_proposals.inject([]) do |array, lot_proposal|
          array << {
            '$class': 'sdc.network.LotProposal',
            'lotId': lot_proposal.lot_id,
            'supplierId': lot_proposal.supplier_id,
            'price_total': lot_proposal.price_total.to_f,
            'delivery_price': lot_proposal.delivery_price.to_f,
            'lot_group_item_lot_proposals': lot_group_items_params(lot_proposal)
          }
        end
      end

      def lot_group_items_params(lot_proposal)
        lot_proposal.lot_group_item_lot_proposals.inject([]) do |array, lot_group_item_lp|
          array << {
                '$class': 'sdc.network.LotGroupItemLotProposal',
                'price': lot_group_item_lp.price.to_f,
                'lotGroupItemId': lot_group_item_lp.lot_group_item.group_item_id,
              }
        end
      end

      def endpoint
        [self.class::ENDPOINT, id].join('/')
      end

      def id; end

      def verb
        'POST'
      end

      def request
        @request ||= begin
          if Rails.env.production?
            @client.request(verb: verb, endpoint: endpoint, params: params)
          else
            bc = Struct.new(:success?)
            bc.new(true)
          end
        end
      end
    end
  end
end

