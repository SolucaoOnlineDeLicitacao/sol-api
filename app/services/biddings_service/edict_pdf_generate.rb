module BiddingsService
  class EdictPdfGenerate
    include TransactionMethods
    include Call::WithExceptionsMethods

    delegate :edict_document, to: :bidding

    def main_method
      pdf_generate
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def pdf_generate
      execute_or_rollback do
        if edict_pdf.present?
          edict_document.present? ? update_edict_document! : update_bidding!
        end
      end
    end

    def update_edict_document!
      edict_document.update!(file: edict_pdf)
    end

    def update_bidding!
      bidding.update!(edict_document: create_edict_document!)
    end

    def create_edict_document!
      Document.create!(file: edict_pdf)
    end

    def edict_pdf
      @edict_pdf ||= Pdf::Builder::Bidding.call(
        header_resource: bidding, html: edict_html_template, file_type: 'edict'
      )
    end

    def edict_html_template
      klass = case bidding.classification.name.downcase
              when 'bens'
                Pdf::Bidding::Edict::TemplateHtml
              when 'serviços'
                Pdf::Bidding::Edict::TemplateHtml
              when 'obras'
                Pdf::Bidding::Edict::TemplateObraHtml
              end      
      klass.call(bidding: bidding)
    end
  end
end
