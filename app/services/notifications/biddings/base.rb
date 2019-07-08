=begin
  Módulo base para criação de notificações de licitações, todos os demais serviços devem
  utilizar este serviço base.

  O serviço base para um recurso deve implementar os métodos initialize e self.call
  e definir os métodos notifiable.

  Aqui também são definidos os métodos auxiliares para facilitar os demais serviços
  herdados deste, como por exemplo os métodos cooperative, users, proposals que são
  utilizados em outros serviços.

=end

module Notifications
  class Biddings::Base < Base

    attr_accessor :bidding

    def initialize(bidding)
      @bidding = bidding
    end

    def self.call(bidding)
      new(bidding).call
    end

    private

    def notifiable
      bidding
    end

    def title_args
      [bidding.title]
    end

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def admin
      @admin ||= bidding.admin
    end

    def users
      @users ||= cooperative.users
    end

    def proposals
      # all proposals, even draft ones
      @proposals ||= bidding.proposals
    end

    def providers
      @providers ||= Provider.joins(:proposals).where(proposals: proposals)
    end

    def suppliers
      @suppliers ||= Supplier.joins(:provider).where(provider: providers)
    end

    def invited_suppliers
      @invited_suppliers ||= Supplier.where(provider_id: bidding.providers)
    end

    def suppliers_from_proposals_and_invites
      [suppliers, invited_suppliers].flatten.uniq
    end
  end
end
