module DoorkeeperTokenAuthenticationHelper

  def oauth_token_sign_in(resource_owner, app: nil, token: nil)
    app   ||= create :oauth_application, scopes: resource_owner.class.name.underscore
    token ||= create :oauth_access_token, resource_owner: resource_owner, application: app, scopes: app.scopes.to_s

    # adding authentication headers
    request.headers.merge! 'Authorization' => "Bearer #{token.token}"

    token
  end

  def oauth_token_sign_out(resource, app: nil, token: nil) # keeping same args for signature consistency
    # erasing authentication headers
    request.headers.merge! 'Authorization' => ''

    token
  end

end


RSpec.configure do |config|
  config.include DoorkeeperTokenAuthenticationHelper, type: :controller
end

