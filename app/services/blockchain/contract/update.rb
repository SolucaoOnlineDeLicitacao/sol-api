require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Contract
    class Update < Base

      def verb
        'PUT'
      end

      def endpoint
        "/api/Contract/#{contract.id}"
      end
    end
  end
end

