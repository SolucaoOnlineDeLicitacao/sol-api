require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class Get < Base
       attr_accessor :proposal

       def call
        get_proposal!
      end

       private

       def get_proposal!
        request
      end

      # gets doenst need params
      def params; end

      def id
        proposal.id
      end

      def verb
        'GET'
      end
    end
  end
end
