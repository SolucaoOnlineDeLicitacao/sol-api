require './lib/api_base/response'

module ApiBlockchain
  class Response < ApiBase::Response
    def success?
      return @status == 204 if @verb == 'DELETE'
      @status == 200
    end
  end
end
