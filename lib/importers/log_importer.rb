module Importers::LogImporter

  def errorify(resource, params={})
    valid = resource.valid?
    skip_params = params.fetch(:skip_errors, nil)
    resource.errors.delete(skip_params) if skip_params.present?

    @errors << resource.errors.full_messages unless valid
  end

  def errors_as_sentence
    [log_header, @errors.flatten.compact.to_sentence].join(': ')
  end

  def log_header
    I18n.t("services.importer.log.resources.#{resource_klass}", value: log_header_title)
  end

  def resource_klass; end

  def log_header_title; end

end
