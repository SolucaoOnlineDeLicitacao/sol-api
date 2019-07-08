require './lib/api_base/client'

module ApiIntegration
  class Client < ApiBase::Client

    def new_connection(request)
      Faraday.new(url: request.endpoint) do |conn|
        conn.options.params_encoder = Faraday::FlatParamsEncoder
        conn.authorization( :Bearer, request.token)
        conn.options.timeout = 1800
        conn.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        conn.adapter @adapter
      end
    end

    def mount_response(response)
      ApiIntegration::Response.new(status: response.status, body: response.body)
    end
  end
end
