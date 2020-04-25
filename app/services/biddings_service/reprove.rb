module BiddingsService
  class Reprove
    include TransactionMethods
    include Call::Methods

    attr_accessor :bidding, :comment, :user, :event

    def initialize(*args)
      super
      @event = Events::BiddingReproved.new(attributes)
    end

    private

    def main_method
      execute_or_rollback do
        event.save!

        updates_bidding_to_review && bidding.reload

        Notifications::Biddings::Reproved.call(bidding)
      end
    end

    def updates_bidding_to_review
      # atualizando a situação com update_attribute para que a atualização seja
      # possível mesmo que a licitação seja inválida - como por exemplo uma reprovação
      # depois do seu dia de abertura
      bidding.update_attribute(:status, :draft)
    end

    def attributes
      {
        from: bidding.status,
        to: 'draft',
        comment: comment,
        eventable: bidding,
        creator: user
      }
    end

  end
end
