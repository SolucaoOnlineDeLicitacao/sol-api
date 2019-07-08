module BiddingsService::Upload::All
  class Strategy
    def self.decide(user:, import:)
      return Xls.new(user: user, import: import) if import.xls?

      Xlsx.new(user: user, import: import)
    end
  end
end
