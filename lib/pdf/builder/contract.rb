module Pdf::Builder
  class Contract < Base
    private

    def cooperative
      @cooperative ||= contract.bidding.cooperative
    end

    def contract
      header_resource
    end
  end
end
