# Disabling unused generators
Rails.application.configure do
  config.generators do |generate|
    generate.helper false
    generate.assets false
    generate.template_engine false # views
  end
end
