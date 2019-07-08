module Pdf::Builder
  class Bidding < Base
    private

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def bidding
      header_resource
    end
  end
end
