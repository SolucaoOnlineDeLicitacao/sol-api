=begin
  Exemplo de "serviço gerenciador" o qual chama os serviços de notificações
  para cada recurso.

  Este serviço também deve responder ao método call (e self.call) para que
  a utilização do serviço gerenciador ou do serviço de notificações seja transparente

=end

module Notifications
  class Biddings::UnderReview

    attr_accessor :bidding

    def initialize(bidding)
      @bidding = bidding
    end

    def self.call(bidding)
      new(bidding).call
    end

    def call
      notify
    end

    private

    def notify
      Notifications::Biddings::UnderReview::Admin.call(bidding)
      Notifications::Biddings::UnderReview::Cooperative.call(bidding)
      Notifications::Biddings::UnderReview::Provider.call(bidding)
    end

  end
end
