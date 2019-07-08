module OAuth
=begin

OAuth Clients/Applications credentials parser.
It tries to parse them, in order, by:
- using the Authorization Basic (HTTP Basic) header
- from `:client_id` and `:client_secret` parameters

NOTE: it has no unit tests since the mechanism is being tested in
      `spec/controllers/oauth/tokens_controller_spec.rb`.

=end
  class ParseClientCredentialsCommand < ::ApplicationCommand

    alias request object
    delegate :params, to: :request

    def initialize(request)
      super
    end


    def call
      if request.authorization.to_s =~ /\ABasic/
        parse_credentials_from_headers
      elsif params[:client_id].present?
        parse_credentials_from_params
      end

      { id: @id, secret: @secret }
    end


    protected

    def parse_credentials_from_headers
      encoded_credentials = request.authorization.to_s.match(/\ABasic\s+(.*)\z/).captures[0]
      @id, @secret = Base64.decode64(encoded_credentials).split(':')
    end

    def parse_credentials_from_params
      @id = params[:client_id]
      @secret = params[:client_secret]
    end

  end
end
