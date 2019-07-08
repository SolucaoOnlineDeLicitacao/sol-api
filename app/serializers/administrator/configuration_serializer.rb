module Administrator
  class ConfigurationSerializer < ActiveModel::Serializer
    attributes :id, :endpoint_url, :token, :schedule, :type, :status,
    :last_importation, :log

    def type
      object.type.split('::')[1].downcase
    end

    def last_importation
      I18n.l(object.last_importation, format: :shorter) if object.last_importation
    end
  end
end
