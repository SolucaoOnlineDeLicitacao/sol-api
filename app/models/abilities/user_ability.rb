module Abilities
  class UserAbility
    include CanCan::Ability

    attr_accessor :user

    def initialize(user)
      @user = user

      can :manage, Provider
      can :manage, Additive, bidding_ongoing_rule
      can :manage, [Bidding, Covenant], cooperative_rule
      can :manage, Contract, user_rule
      can :manage, [LotGroupItem, Proposal, Lot, Invite], bidding_rule
      can :manage, LotProposal, lot_rule
      can :manage, Group, covenant_rule
      can :manage, GroupItem, group_rule
      can :manage, Notification, notification_rule
      can :manage, User, basic_rule
      can :mark_as_read, Notification
    end

    private

    def basic_rule
      { id: user.id }
    end

    def user_rule
      { user: basic_rule }
    end

    def users_rule
      { users: basic_rule }
    end

    def cooperative_rule
      { cooperative: users_rule }
    end

    def bidding_rule
      { bidding: cooperative_rule }
    end

    def bidding_ongoing_rule
      { bidding: cooperative_rule.merge(status: :ongoing) }
    end

    def covenant_rule
      { covenant: cooperative_rule }
    end

    def group_rule
      { group: covenant_rule }
    end

    def lot_rule
      { lot: bidding_rule }
    end

    def notification_rule
      { id: user.notifications }
    end
  end
end
