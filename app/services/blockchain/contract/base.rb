require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Contract
    class Base
      include TransactionMethods
      include Call::WithExceptionsMethods

      attr_accessor :client

      def initialize(*args)
        @client = ApiBlockchain::Client.new
        super
      end

      def main_method
        request!
      end

      def call_exception
        BlockchainError
      end

      private

      def request!
        execute_or_rollback do
          raise BlockchainError unless request.success?
        end
      end

      def request
        @request ||= begin
          if Rails.env.production?
            client.request(verb: verb, endpoint: endpoint, params: params)
          else
            bc = Struct.new(:success?)
            bc.new(true)
          end
        end
      end

      def params
        base_params
          .merge(supplier_params)
          .merge(deleted_params)
          .merge(refused_by_params)
          .except(remove_contract_params)
      end

      def base_params
        {
          "$class" => "sdc.network.Contract",
          "contractHash" => contract.id.to_s,
          "contractId" => contract.id.to_s,
          "bidding" => "resource:sdc.network.Bidding##{contract.bidding.id}",
          "status" => contract.status.upcase,
          "price_total" => contract.proposal.price_total.to_f,
          "user_signed_at" => contract.user_signed_at,
          "user_id" => contract.user_id,
          "quantity" => contract.lot_group_items.map(&:quantity).sum,
          "proposal" => "resource:sdc.network.Proposal##{contract.proposal_id}",
          "returnedLotGroupItems" => returned_lot_group_item
        }
      end

      def remove_contract_params
        return nil unless self.is_a? Blockchain::Contract::Update
        "contractId"
      end

      def supplier_params
        return {} unless contract.supplier
        {
          "supplier_signed_at" => contract.supplier_signed_at,
          "supplier_id" => contract.supplier_id
        }
      end

      def deleted_params
        return {} unless contract.deleted_at
        {
          "deleted_at" => contract.deleted_at
        }
      end

      def refused_by_params
        return {} unless contract.refused_by_id
        {
          "refused_by_type" => contract.refused_by_type.upcase,
          "refused_by_id" => contract.refused_by_id.to_s,
          "refused_at" => contract.refused_by_at
        }
      end

      def returned_lot_group_item
        contract.lot_group_items_returned.map do |lot_group_item|
          {
            "$class" => "sdc.network.ReturnedLotGroupItem",
            "returnedLotGroupItemId" => lot_group_item.id,
            "quantity" => lot_group_item.quantity,
            "lot_group_item_id" => lot_group_item.lot_id.to_s
          }
        end
      end
    end
  end
end

