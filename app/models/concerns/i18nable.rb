module I18nable
  extend ActiveSupport::Concern

  included do
    # indexes should not be changed, new languages should be index + 1
    enum locale: { 'pt-BR': 0, 'en-US': 1, 'es-PY': 2, 'fr-FR': 3 }
  end
end
