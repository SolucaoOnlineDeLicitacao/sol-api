=begin
  Módulo base para criação de notificações de propostas globais,
  todos os demais serviços devem utilizar este serviço base.

  O serviço base para um recurso deve implementar os métodos initialize e self.call
  e definir os métodos notifiable.

  Aqui também são definidos os métodos auxiliares para facilitar os demais serviços
  herdados deste, como por exemplo os métodos cooperative, admin, users etc.

  Também podemos definir os extra_args (e demais métodos) caso eles sejam os mesmos
  para todos os demais serviços de convites.

=end

module Notifications
  class Proposals::Base < Base

    attr_accessor :proposal, :bidding

    def initialize(proposal)
      @proposal = proposal
      @bidding = proposal.bidding
    end

    def self.call(proposal)
      new(proposal).call
    end

    private

    def notifiable
      proposal
    end

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def extra_args
      { bidding_id: bidding.id }
    end

    def body_args
      bidding.title
    end

    def admin
      @admin ||= bidding.admin
    end

    def users
      @users ||= cooperative.users
    end

    def provider
      @provider ||= proposal.provider
    end

  end
end
