module Abilities::Admin
  class ReviewerAbility < Base
    include CanCan::Ability

    attr_accessor :user

    def initialize(user)
      @user = user

      if exist_integration?
        can :read, Covenant, admin_rule
        can :read, Group, covenant_rule
        can :read, Cooperative, covenants_rule
        can :read, Item, group_items_rule
        can :read, GroupItem, group_rule
      else
        can :manage, Covenant, admin_rule
        can :manage, Group, covenant_rule
        can :manage, Cooperative, covenants_rule
        can :manage, Item, group_items_rule
        can :manage, GroupItem, group_rule
      end

      can :manage, Contract, bidding_rule
      can :manage, Bidding, covenant_rule
      can :manage, Proposal, bidding_rule
      can :manage, Lot, bidding_rule
      can :manage, LotProposal, lot_rule
      can :read, Admin
      can [:update, :profile], Admin, basic_rule
      can :manage, Provider, bidding_rule
      can :manage, Supplier, provider_rule
      can :manage, Unit, items_rule
      can :manage, User, cooperative_rule
      can :manage, Notification, notification_rule
      can :mark_as_read, Notification
      can :manage, Report, admin_rule
    end

    private

    def basic_rule
      { id: user.id }
    end

    def admin_rule
      { admin: basic_rule }
    end

    def covenant_rule
      { covenant: admin_rule }
    end

    def covenants_rule
      { covenants: admin_rule }
    end

    def bidding_rule
      { bidding: covenant_rule }
    end

    def lot_rule
      { lot: bidding_rule }
    end

    def group_rule
      { group: covenant_rule }
    end

    def group_items_rule
      { group_items: group_rule }
    end

    def provider_rule
      { provider: bidding_rule }
    end

    def items_rule
      { items: group_items_rule }
    end

    def cooperative_rule
      { cooperative: covenants_rule }
    end

    def notification_rule
      { id: user.notifications }
    end
  end
end
