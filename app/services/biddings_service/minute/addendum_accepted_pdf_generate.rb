module BiddingsService::Minute
  class AddendumAcceptedPdfGenerate < Base
    delegate :bidding, to: :contract

    private

    def minute_html_template
      Pdf::Bidding::Minute::Addendum::AcceptedHtml.call(contract: contract)
    end

    def file_type
      'minute_addendum'
    end
  end
end
