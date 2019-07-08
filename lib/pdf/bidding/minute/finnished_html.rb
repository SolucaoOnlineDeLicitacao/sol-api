module Pdf::Bidding
  class Minute::FinnishedHtml < Minute::Base
    private

    def bidding_not_able_to_generate?
      !bidding.finnished?
    end

    def template_file_name
      'minute_finnished.html'
    end
  end
end
