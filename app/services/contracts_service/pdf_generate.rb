module ContractsService
  class PdfGenerate
    include TransactionMethods
    include Call::WithExceptionsMethods

    delegate :document, to: :contract

    def main_method
      pdf_generate
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def pdf_generate
      execute_or_rollback do
        if contract_pdf.present?
          document.present? ? update_document! : update_contract!
        end
      end
    end

    def update_document!
      document.update!(file: contract_pdf)
    end

    def update_contract!
      contract.update!(document: create_document!)
    end

    def create_document!
      Document.create!(file: contract_pdf)
    end

    def contract_pdf
      @contract_pdf ||= Pdf::Builder::Contract.call(
        { html: contract_html_template, file_type: 'contract' }.merge(contract_decide)
      )
    end

    def contract_decide
      return { header_resource: contract } if contract.classification_name.downcase == 'bens'
      { }
    end

    def contract_html_template
      contract_template_service.call
    end

    def contract_template_service
      @contract_template_service ||= Pdf::Contract::TemplateStrategy.decide(contract: contract)
    end
  end
end
