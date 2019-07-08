module BiddingsService
  class Failure
    include TransactionMethods
    include Call::Methods

    attr_accessor :bidding, :comment, :creator, :event_service

    def initialize(*args)
      super
      @event_service = event_failure_service
    end

    def main_method
      execute_and_perform
    end

    private

    def execute_and_perform
      generate_minute if bidding_failure
      bidding_failure
    end

    def bidding_failure
      @bidding_failure ||= begin
        execute_or_rollback do
          bidding.force_failure!
          bidding.failure!
          bidding.reload
          save_event!
          update_bidding_blockchain!
          recalculate_quantity!
          clone_bidding!
          notify
        end
      end
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def clone_bidding!
      BiddingsService::Clone.call!(bidding: bidding)
    end

    def update_bidding_blockchain!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def save_event!
      event_service.call
      raise ActiveRecord::RecordInvalid unless event.valid?
    end

    def event_failure_service
      EventServices::Bidding::Failure.new(attributes)
    end

    def event
      @event ||= event_service.event
    end

    def attributes
      {
        bidding: bidding,
        comment: comment,
        creator: creator
      }
    end

    def notify
      Notifications::Biddings::FailureAll.call(bidding: bidding)
    end

    def generate_minute
      Bidding::Minute::PdfGenerateWorker.perform_async(bidding.id)
    end
  end
end
