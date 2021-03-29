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
      respond_to_header? ? base_options.merge(header_cooperative_options) : base_options
    end

    def respond_to_header?
      respond_to?('header_resource') && header_resource.present?
    end

    def base_options
      options = { encoding:'UTF-8', page_size: 'A4', print_media_type: true }
      options = options.merge(header_options)
      options = options.merge(footer_options)
      options
    end

    def header_options
      { header_html: render_header_footer('header'), margin_top: '2.5in', header_spacing: '10' }
    end

    def footer_options
      { footer_html: render_header_footer('footer'), footer_right: '[page]/[topage]', footer_font_size: '7' }
    end

    def header_cooperative_options
      { header_center: header_center, header_spacing: '40' }
    end

    def header_center
      "\n\n#{wrap(cooperative.name)}\n"\
      "#{cooperative.cnpj}\n"\
      "#{wrap(cooperative_address)}"
    end

    def cooperative_address
      "#{cooperative.address.address}, "\
      "#{cooperative.address.city.name} - "\
      "#{cooperative.address.city.state.name}"
    end

    def wrap(s, width=60)
      s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
    end

    # Render the footer out to a temp file
    # PDFkit will only accept a file or URL, it will not accept raw text the way you expect.
    # ie; passing the erb compiled output directly back to pdfkit results in non-dynamic content being displayed.
    def render_header_footer(type)
      compiled = ERB.new(File.read("#{Rails.root}/app/views/reports/#{type}.html.erb")).result(binding)
      file = Tempfile.new(["#{type}",".html"])
      file.write(compiled)
      file.rewind
      file.path
    end

    def filepath
      Rails.root.join('storage', filename)
    end

    def filename
      @filename ||= "#{DateTime.current.to_i}_#{Random.rand(99999)}_#{file_type}.pdf"
    end

    # override
    def cooperative; end
  end
end
