=begin
  Módulo base para criação de notificações de contratos, todos os demais serviços devem
  utilizar este serviço base.

  O serviço base para um recurso deve implementar os métodos initialize e self.call
  e definir os métodos notifiable.

  Aqui também são definidos os métodos auxiliares para facilitar os demais serviços
  herdados deste, como por exemplo os métodos admin, user, supplier que são
  utilizados em outros serviços.

=end

module Notifications
  class Contracts::Base < Base
    include Call::Methods

    def main_method
      notify
    end

    private

    def notifiable
      contract
    end

    def extra_args
      { bidding_id: bidding.id }
    end

    def admin
      @admin ||= bidding.admin
    end

    def bidding
      @bidding ||= contract.bidding
    end

    def user
      @user ||= contract.user
    end

    def supplier
      @supplier ||= contract.supplier
    end

    def proposal
      @proposal ||= contract.proposal
    end

    def provider
      @provider ||= proposal.provider
    end

    def suppliers
      @suppliers ||= provider.suppliers
    end
  end
end
