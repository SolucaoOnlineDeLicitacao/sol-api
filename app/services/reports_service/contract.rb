module ReportsService
  class Contract < ReportsService::BaseContract

    private

    def classifications
      @classifications ||= ::Classification.where(classification_id: nil).order(:id)
    end

    def classification_contracts(classification)
      contracts_children = classification_children_contracts(classification)
      contracts_base = by_classification(classification.id)
      [contracts_children + contracts_base].uniq.flatten
    end

    def classification_children_contracts(classification)
      classification_ids = classification.children_classifications.map(&:id)
      by_classification(classification_ids).uniq
    end

    def name_count_price(contracts, classification)
      {
        label: classification.name,
        data: {
          countable: contracts.count,
          price_total: price_total(contracts)
        }
      }
    end
  end
end
