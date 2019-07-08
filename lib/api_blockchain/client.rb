require './lib/api_base/client'

module ApiBlockchain
  class Client < ApiBase::Client
    # override to remove token_auth
    def request(verb: 'POST', endpoint:, params: {})
      request_params = OpenStruct.new(verb: verb, endpoint: endpoint, params: params)
      make_request(request_params)
    end

    def new_connection(request)
      if auth_needed?
        jwt_conn.get auth_path
        jwt_conn.headers = jwt_conn.headers.except!("Authorization")
      end

      jwt_conn
    end

    def jwt_conn
      @jwt_conn ||= Faraday.new(url: base_path) do |conn|
        conn.options.params_encoder = Faraday::FlatParamsEncoder
        conn.options.timeout = 1800
        conn.use :cookie_jar
        conn.authorization(:Bearer, token)
        conn.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        conn.request :json
        conn.adapter @adapter
      end
    end

    def auth_needed?
      jwt_conn.builder.app.as_json["jar"].none?{ |h| h["name"] == "access_token" }
    end

    def token
      @token ||= JWT.encode payload, Rails.application.secrets.dig(:blockchain, :hyperledger_jwt_secret), 'HS256'
    end

    def base_path
      @base_path ||= Rails.application.secrets.dig(:blockchain, :hyperledger_path)
    end

    def auth_path
      @auth_path ||= Rails.application.secrets.dig(:blockchain, :hyperledger_jwt_auth_path)
    end

    def payload
      @payload ||= { username: 'bc-bahia' }
    end

    def mount_response(response)
      ApiBlockchain::Response.new(status: response.status, body: response.body, verb: verb(response))
    end

    def verb(response)
      response.env.method.to_s.upcase
    end
  end
end
