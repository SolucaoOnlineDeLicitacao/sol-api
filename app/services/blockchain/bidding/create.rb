require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Bidding
    class Create < Base

      attr_accessor :bidding

      def call
        create_bidding!
      end

      private

      def create_bidding!
        request
      end
    end
  end
end

