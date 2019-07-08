module BiddingsService::Minute
  class AddendumPdfGenerate < Base
    delegate :bidding, to: :contract

    private

    def minute_html_template
      Pdf::Bidding::Minute::Addendum::Html.call(contract: contract)
    end

    def file_type
      'minute_addendum'
    end
  end
end
