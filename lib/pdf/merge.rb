module Pdf
  class Merge
    include Call::Methods

    def main_method
      generate
    end

    private

    def generate
      return if documents.blank?

      pdf = CombinePDF.new
      documents.each { |document| pdf << CombinePDF.load(document.file.path) }
      pdf.save(filepath)

      filepath.open
    end

    def filepath
      Rails.root.join('storage', filename)
    end

    def filename
      @filename ||= "#{DateTime.current.to_i}_#{Random.rand(99999)}_merged_minute.pdf"
    end
  end
end
