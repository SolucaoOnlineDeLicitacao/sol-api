require 'faraday'

module ApiBase
  class Client
    attr_reader :adapter, :connection

    def initialize(adapter: Faraday.default_adapter)
      @adapter = adapter
      @connection = nil
    end

    def request(verb: 'GET', endpoint:, token:, params: {})
      request_params = OpenStruct.new(
        verb: verb, endpoint: endpoint,
        token: token, params: params
      )
      make_request(request_params)
    end

    private

    def make_request(request)
      @connection = new_connection(request)

      response = fetch_response(request)

      mount_response(response)
    end

    def mount_response(response)
      ApiBase::Response.new(status: response.status, body: response.body)
    end

    def new_connection(request)
      Faraday.new(url: request.endpoint) do |conn|
        conn.options.params_encoder = Faraday::FlatParamsEncoder
        conn.token_auth(request.token)
        conn.options.timeout = 1800
        conn.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        conn.adapter @adapter
      end
    end

    def fetch_response(request)
      @connection.send(request.verb.downcase.to_sym, request.endpoint, request.params)
    end
  end
end
