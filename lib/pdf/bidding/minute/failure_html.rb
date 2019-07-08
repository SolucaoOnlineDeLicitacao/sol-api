module Pdf::Bidding
  class Minute::FailureHtml < Minute::Base
    private

    def bidding_not_able_to_generate?
      !bidding.failure?
    end

    def template_file_name
      'minute_failure.html'
    end
  end
end
