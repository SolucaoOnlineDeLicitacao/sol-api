module Abilities
  class Strategy
    include Call::Methods

    def main_method
      build
    end

    private

    def build
      if admin_user?
        if user.reviewer?
          Abilities::Admin::ReviewerAbility.new(user)
        elsif user.general?
          Abilities::Admin::GeneralAbility.new(user)
        elsif user.viewer?
          Abilities::Admin::ViewerAbility.new(user)
        end

      elsif supplier_user?
        Abilities::SupplierAbility.new(user)

      elsif user?
        Abilities::UserAbility.new(user)

      end
    end

    def admin_user?
      user.class.name == 'Admin'
    end

    def supplier_user?
      user.class.name == 'Supplier'
    end

    def user?
      user.class.name == 'User'
    end
  end
end
