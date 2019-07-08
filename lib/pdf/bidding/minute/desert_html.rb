module Pdf::Bidding
  class Minute::DesertHtml < Minute::Base
    private

    def bidding_not_able_to_generate?
      !bidding.desert?
    end

    def template_file_name
      'minute_desert.html'
    end
  end
end
