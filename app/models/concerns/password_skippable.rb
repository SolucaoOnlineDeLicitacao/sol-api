module PasswordSkippable
  extend ActiveSupport::Concern

  included do
    # skips password if integrated resource
    attr_accessor :skip_password_validation

    def skip_password_validation!
      @skip_password_validation = true
    end

    protected

    def password_required?
      return false if skip_password_validation
      super
    end
  end
end
