module Pdf::Bidding
  class Minute::TemplateStrategy
    def self.decide(bidding:)
      klass = case bidding.status
              when 'finnished'
                Pdf::Bidding::Minute::FinnishedHtml
              when 'failure'
                Pdf::Bidding::Minute::FailureHtml
              when 'desert'
                Pdf::Bidding::Minute::DesertHtml
              end
      klass.new(bidding: bidding)
    end
  end
end
