module Pdf::Bidding::Minute
  class Addendum::AcceptedHtml < Addendum::Base
    private

    def template_file_name
      'addendum_accepted.html'
    end
  end
end
