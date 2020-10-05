Doorkeeper.configure do
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    raise "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
  end

  # @see https://stackoverflow.com/a/26537028
  resource_owner_from_credentials do |routes|
    # ensuring client credentials
    client_credentials = OAuth::ParseClientCredentialsCommand.call request
    application = Doorkeeper::Application.find_by uid: client_credentials[:id], secret: client_credentials[:secret]

    raise Doorkeeper::Errors::DoorkeeperError, :invalid_client unless application

    resource_owner_class = Doorkeeper::Extensions::ResourceOwnerClassFromScopeCommand.call(application.scopes)

    # Using Devise's database authenticable finder method
    resource_owner = resource_owner_class.find_for_database_authentication(email: params[:username])

    raise Doorkeeper::Errors::DoorkeeperError, :blocked if resource_owner && resource_owner.is_a?(Supplier) && resource_owner.provider.blocked?

    # Using Devise's authentication methods
    resource_owner if resource_owner&.valid_for_authentication? { resource_owner.valid_password?(params[:password]) }
  end

  api_only
  access_token_expires_in nil # never expires
  base_controller 'ApplicationController'
  enforce_configured_scopes
  default_scopes  :public
  optional_scopes :admin, :supplier, :user, :read, :write
  grant_flows %w[password]
end

module DoorkeeperExtensionClientScopeGuard
  def scopes
    @scopes ||= client.try(:scopes) || default_scopes
  end
end

Doorkeeper::OAuth::PasswordAccessTokenRequest.send :prepend, DoorkeeperExtensionClientScopeGuard

module DoorkeeperExtensionResourceOwnerTokenResponse
  def body
    resource_owner = Doorkeeper::Extensions::ResourceOwnerFromTokenCommand.call(token)

    base_params = {
      'id'       => token.resource_owner_id,
      'name'     => resource_owner.name,
      'username' => resource_owner.email,
      'locale'   => resource_owner.locale
    }

    if resource_owner.is_a?(Admin) && resource_owner.respond_to?(:role)
      base_params = admin_params(base_params, resource_owner)
    end

    if (resource_owner.is_a?(User) || resource_owner.is_a?(Supplier)) &&
       resource_owner.respond_to?(:avatar)
      base_params = base_params.merge('avatar' => { 'url' => resource_owner.avatar.url })
    end

    # call original `#body` method and merge its result with the additional data hash
    super.merge('user' => base_params)
  end

  def admin_params(base_params, resource_owner)
    base_params.merge({ 'role' => resource_owner.role, 'rules' => rules(resource_owner) })
  end

  def rules(resource_owner)
    Abilities::Strategy.call(user: resource_owner).as_json
  end
end

Doorkeeper::OAuth::TokenResponse.send :prepend, DoorkeeperExtensionResourceOwnerTokenResponse
