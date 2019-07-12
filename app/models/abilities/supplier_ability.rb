module Abilities
  class SupplierAbility
    include CanCan::Ability

    attr_accessor :user

    def initialize(user)
      @user = user

      return update_revoked_at if user.provider.blocked

      can :manage, Bidding, Bidding.all do |bidding|
        Policies::Bidding::ManagePolicy.allowed?(bidding, user.provider)
      end

      can :manage, Lot

      can [:index, :show], Proposal, Proposal.read_policy_by(user.id) do |proposal|
        Policies::Proposal::ReadPolicy.allowed?(proposal, user)
      end

      can [:index, :show], LotProposal, LotProposal.read_policy_by(user.id) do |lot_proposal|
        Policies::LotProposal::ReadPolicy.allowed?(lot_proposal, user)
      end

      can :manage, Contract, contract_rule
      can :manage, Notification, notification_rule

      can :manage, Invite, invite_rule

      can [:create, :update, :destroy, :finish], Proposal do |proposal|
        Policies::Proposal::SendPolicy.allowed?(proposal)
      end

      can [:create, :update, :destroy], LotProposal do |lot_proposal|
        Policies::Proposal::SendPolicy.allowed?(lot_proposal.proposal)
      end

      can :manage, [ProposalImport, LotProposalImport] do |proposal_import|
        Policies::Proposal::UploadPolicy.allowed?(proposal_import)
      end

      can :manage, Supplier, basic_rule

      can :mark_as_read, Notification
    end

    private

    def update_revoked_at
      user.access_tokens.where(revoked_at: nil).update_all(revoked_at: DateTime.current)
    end

    def basic_rule
      { id: user.id }
    end

    def contract_rule
      { proposal: { provider: { suppliers: basic_rule } } }
    end

    def invite_rule
      { bidding: { modality: [:open_invite, :closed_invite] } }
    end

    def notification_rule
      { id: user.notifications }
    end
  end
end
