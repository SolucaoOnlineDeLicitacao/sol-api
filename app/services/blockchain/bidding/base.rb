require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Bidding
    class Base

      attr_accessor :bidding

      ENDPOINT = "/api/Bidding"

      def self.call(bidding)
        new(bidding).call
      end

      def initialize(bidding)
        @bidding = bidding
        @client = ApiBlockchain::Client.new
      end

      def call
        raise NotImplementedError
      end

      private

      def params
        params = {
          "$class": "sdc.network.Bidding",
          "biddingId": bidding.id,
          "title": bidding.title,
          "description": bidding.description,
          "covenantId": bidding.covenant_id,
          "covenantDescription": bidding.covenant.name,
          "deadline": bidding.deadline,
          "start_date": bidding.start_date,
          "closing_date": bidding.closing_date,
          "kind": bidding.kind.upcase,
          "status": bidding.status.upcase,
          "lots": lots_params,
          "modality": bidding.modality.upcase,
          "draw_end_days": bidding.draw_end_days,
          "draw_at": bidding.draw_at
        }
        params = merge_parent_id(params) if bidding.parent_id
        params
      end

      def merge_parent_id(params)
        params_merge(
          params, "parent_id": bidding.parent_id
        )
      end

      def params_merge(params, keys = {})
        params.merge(keys)
      end

      def lots_params
        bidding.lots.inject([]) do |array, lot|
          array << {
            "$class": "sdc.network.Lot",
            "lotId": lot.id,
            "name": lot.name,
            "status": lot.status.upcase,
            "lot_group_items": lot_group_items_params(lot)
          }
        end
      end

      def lot_group_items_params(lot)
        lot.lot_group_items.inject([]) do |array, lot_group_item|
          array << {
                "$class": "sdc.network.LotGroupItem",
                "quantity": lot_group_item.quantity,
                "groupItemId": lot_group_item.group_item_id,
              }
        end
      end

      def endpoint
        self.class::ENDPOINT
      end

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

