module BiddingsService::Minute
  class Base
    include TransactionMethods
    include Call::WithExceptionsMethods

    delegate :minute_documents, to: :bidding

    def main_method
      pdf_generate
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def pdf_generate
      execute_or_rollback do
        if minute_pdf.present?
          attach_minute_document!
          merge_all_minute_documents!
        end
      end
    end

    def attach_minute_document!
      minute_documents << create_minute_document!
      bidding.save!
    end

    def merge_all_minute_documents!
      bidding.update!(merged_minute_document: create_merged_minute_document!)
    end

    def create_minute_document!
      create_document!(:minute_pdf)
    end

    def create_merged_minute_document!
      create_document!(:merged_minute_pdf)
    end

    def create_document!(file_method)
      Document.create!(file: send(file_method))
    end

    def minute_pdf
      @minute_pdf ||= Pdf::Builder::Bidding.call(html: minute_html_template, file_type: file_type)
    end

    def merged_minute_pdf
      Pdf::Merge.call(documents: minute_documents)
    end

    # override
    def minute_html_template; end
    def file_type; end
  end
end
