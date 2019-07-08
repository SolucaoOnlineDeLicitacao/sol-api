=begin
  Módulo base para criação de notificações de convites, todos os demais serviços devem
  utilizar este serviço base.

  O serviço base para um recurso deve implementar os métodos initialize e self.call
  e definir os métodos notifiable.

  Aqui também são definidos os métodos auxiliares para facilitar os demais serviços
  herdados deste, como por exemplo os métodos suppliers, cooperative etc.

  Também podemos definir os extra_args (e demais métodos) caso eles sejam os mesmos
  para todos os demais serviços de convites.

=end

module Notifications
  class Invites::Base < Base

    attr_accessor :invite, :bidding, :provider

    def initialize(invite)
      @invite = invite
      @bidding = invite.bidding
      @provider = invite.provider
    end

    def self.call(invite)
      new(invite).call
    end

    private

    def notifiable
      @invite
    end

    def extra_args
      { bidding_id: bidding.id }
    end

    def suppliers
      @suppliers ||= provider.suppliers
    end

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def users
      @users ||= cooperative.users
    end
  end
end
