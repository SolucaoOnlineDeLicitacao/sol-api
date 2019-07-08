module Pdf::Builder
  class Base
    include Call::Methods

    def main_method
      builds
    end

    private

    def builds
      return if html.blank?

      kit = PDFKit.new(html, options)
      kit.to_file(filepath)

      filepath.open
    end

    def options
      respond_to_header? ? base_options.merge(header_options) : base_options
    end

    def respond_to_header?
      respond_to?('header_resource') && header_resource.present?
    end

    def base_options
      { page_size: 'A4', print_media_type: true }
    end

    def header_options
      { margin_top: '2.5in', header_spacing: '40', header_center: header_center }
    end

    def filepath
      Rails.root.join('storage', filename)
    end

    def filename
      @filename ||= "#{DateTime.current.to_i}_#{Random.rand(99999)}_#{file_type}.pdf"
    end

    def header_center
      "#{wrap(cooperative.name)}\n"\
      "#{cooperative.cnpj}\n"\
      "#{cooperative.address.address}, "\
      "#{cooperative.address.city.name} - "\
      "#{cooperative.address.city.state.name}"
    end

    def wrap(s, width=60)
      s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
    end

    # override
    def cooperative; end
  end
end
