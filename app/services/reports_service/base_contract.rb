module ReportsService
  class BaseContract

    def initialize; end

    def self.call
      new.call
    end

    def call
      report
    end

    private

    def report
      classifications.inject([]) do |array, classification|
        contracts = classification_contracts(classification)
        array << name_count_price(contracts, classification)
        array
      end
    end

    def classifications; end

    def name_count_price(contracts, classification); end

    def price_total(contracts)
      contracts.map(&:price_by_proposal_accepted).sum
    end

    def by_classification(classification_id)
      ::Contract.by_classification(classification_id)
    end
  end
end
