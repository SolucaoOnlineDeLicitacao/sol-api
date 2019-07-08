module Notifications
  class Biddings::Ongoing::ClassificationProvider < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      suppliers
    end

    def providers
      @providers ||= Provider.with_suppliers.by_classification(classifications)
    end

    def classifications
      bidding.classification.children_classifications
    end
  end
end
