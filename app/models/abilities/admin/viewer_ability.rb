module Abilities::Admin
  class ViewerAbility < Base
    include CanCan::Ability

    def initialize(user)
      can :read, :all
      can [:unreads_count, :mark_as_read], Notification
      can [:update, :profile], Admin, id: user.id
      can :manage, Report, admin: { id: user.id }
    end
  end
end
