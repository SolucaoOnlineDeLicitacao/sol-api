module Abilities::Admin
  class GeneralAbility < Base
    include CanCan::Ability

    INTEGRATION_MODELS = [
      Covenant, Group, Cooperative, Item, GroupItem
    ].freeze

    NOT_INTEGRATION_MODELS = [
      Contract, Bidding, Proposal, Lot, LotProposal, Admin, Provider, Supplier,
      Unit, User, Notification, Report
    ].freeze

    def initialize(user)
      if exist_integration?
        can :read, INTEGRATION_MODELS
        can :manage, NOT_INTEGRATION_MODELS
      else
        can :manage, INTEGRATION_MODELS + NOT_INTEGRATION_MODELS
      end
    end
  end
end
