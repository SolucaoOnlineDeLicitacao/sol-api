module ReportsService
  class Classification < ReportsService::BaseContract

    private

    def classifications
      @classifications ||= ::Classification.all.order(:id)
    end

    def classification_contracts(classification)
      if base?(classification)
        base_classification_contracts(classification)
      else
        by_classification(classification.id).uniq
      end
    end

    def base?(classification)
      classification.classification_id.nil?
    end

    def base_classification_contracts(classification)
      by_classification(classification.base_classification.id)
    end

    def name_count_price(contracts, classification)
      {
        classification: classification,
        contracts: contracts.to_a, 
        price_total: price_total(contracts)
      }
    end
  end
end
