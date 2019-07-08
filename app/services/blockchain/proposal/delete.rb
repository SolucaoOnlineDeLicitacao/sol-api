require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class Delete < Base

      attr_accessor :proposal

      def call
        delete_proposal!
      end

      private

      def delete_proposal!
        request
      end

      def params; end

      def id
        proposal.id
      end
      
      def verb
        'DELETE'
      end
    end
  end
end

