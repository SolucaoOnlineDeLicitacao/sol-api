module ApiBase
  class Response
    attr_accessor :status, :body, :verb

    def initialize(status:, body:, verb: 'POST')
      @status = status
      @body = parse(body)
      @verb = verb
    end

    def success?
      @status == 200
    end

    private

    def parse(body)
      Array.wrap(body)
    end
  end
end
