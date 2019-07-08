require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Bidding
    class Update < Base
      attr_accessor :bidding

      def call
        update_bidding!
      end

      private

      def update_bidding!
        request
      end

      def endpoint
        super + "/#{bidding.id}"
      end

      def verb
        'PUT'
      end
    end
  end
end

