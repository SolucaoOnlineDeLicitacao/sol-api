module Pdf::Bidding::Minute
  class Addendum::Html < Addendum::Base
    private

    def template_file_name
      'addendum.html'
    end
  end
end
