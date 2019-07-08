module Doorkeeper::Extensions
  class ResourceOwnerClassFromScopeCommand < ::ApplicationCommand

    alias scope object

    #
    # usage:
    #   klass = ResourceOwnerClassFromScopeCommand.call(application.scopes)
    #   klass = ResourceOwnerClassFromScopeCommand.call(current_token.application.scopes)
    #
    def initialize(scope)
      super
    end

    def call
      case scope.to_s
      when /admin/i then Admin
      when /supplier/i then Supplier
      # when /user/i # default
      else User
      end
    end

  end
end
