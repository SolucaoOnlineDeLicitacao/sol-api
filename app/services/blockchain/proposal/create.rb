require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class Create < Base

      attr_accessor :proposal

      def call
        create_proposal!
      end

      private

      def create_proposal!
        request
      end
    end
  end
end

