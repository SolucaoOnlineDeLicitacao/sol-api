require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Contract
    class Create < Base

      def verb
        'POST'
      end

      def endpoint
        "/api/Contract"
      end
    end
  end
end

