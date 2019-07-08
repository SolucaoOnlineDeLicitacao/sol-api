module Pdf::Contract
  class TemplateStrategy
    def self.decide(contract:)
      klass = case contract.classification_name.downcase
              when 'bens'
                Pdf::Contract::Classification::Commodity
              when 'serviços'
                Pdf::Contract::Classification::Service
              when 'obras'
                Pdf::Contract::Classification::Work
              end
      klass.new(contract: contract)
    end

  end
end
