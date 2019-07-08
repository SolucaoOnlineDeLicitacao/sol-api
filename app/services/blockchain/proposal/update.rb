require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class Update < Base

      attr_accessor :proposal

      def call
        update_proposal!
      end

      private

      def update_proposal!
        request
      end

      # connection

      def id
        proposal.id
      end

      def verb
        'PUT'
      end
    end
  end
end

