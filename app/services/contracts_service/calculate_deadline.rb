module ContractsService
  class CalculateDeadline
    include Call::Methods

    DEADLINE_SUM = 60.freeze
    
    def main_method
      calculate_deadline
    end

    private

    def calculate_deadline
      deadline_values.map(&:to_i).max.to_i + DEADLINE_SUM
    end

    def bidding
      @bidding ||= lots.first.bidding
    end

    def deadline_values
      @deadline_values ||= lots.map(&:deadline).map{ |value| value.blank? ? bidding.deadline : value }
    end
  end
end
