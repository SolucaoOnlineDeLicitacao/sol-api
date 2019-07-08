module Integration::LogImporter

  private

  def start!
    @configuration.log = ""
    @configuration.last_importation = Time.now
    @configuration.status_in_progress!

    log(:info, I18n.t("services.importer.log.start"))
  end

  def close_log
    log(:info, I18n.t('services.importer.log.end'))
  end

  def log(type, message)
    @configuration.log << "[#{type.upcase}] #{build_message(message)}"
  end

  def build_message(message)
    "#{message} - #{I18n.l(Time.now, format: :shorter)} \n"
  end

  def log_path
    if Rails.env.test?
      Rails.root.to_s + '/log/test_integrations_importer.log'
    else
      Rails.root.to_s + '/log/integrations_importer.log'
    end
  end
end
