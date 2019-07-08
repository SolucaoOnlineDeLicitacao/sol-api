module Doorkeeper::Extensions
  class ResourceOwnerFromTokenCommand < ::ApplicationCommand

    alias token object

    def initialize(token)
      super
    end

    def call
      application = token.application
      resource_owner_class = ResourceOwnerClassFromScopeCommand.call(application.scopes)
      resource_owner = resource_owner_class.find token.resource_owner_id

      resource_owner
    end

  end
end
