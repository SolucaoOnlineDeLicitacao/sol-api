module ReportsService
  class Bidding

    STATUSES = ::Bidding.statuses.keys.except("draft").freeze

    def initialize; end

    def self.call
      new.call
    end

    def call
      report
    end

    private

    def report
      STATUSES.inject([]) do |array, key|
        array << { label: key.to_sym, data: count_price(::Bidding.send("#{key}")) }
        array
      end
    end

    def count_price(biddings)
      {
        countable: biddings.count,
        price_total: price_total(biddings),
        estimated_cost: estimated_cost(biddings)
      }
    end

    def price_total(biddings)
      biddings.joins(:proposals).where(proposals: { status: 'accepted' }).sum(:'proposals.price_total')
    end

    def estimated_cost(biddings)
      biddings.joins(:group_items).sum('group_items.estimated_cost')
    end
  end
end
