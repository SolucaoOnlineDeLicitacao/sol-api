module CovenantSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :name, :number, :status, :signature_date, :validity_date,
               :cooperative_id, :cooperative_name, :cooperative_address_city_name,
               :admin_id, :admin_name, :estimated_cost, :city_text, :city_id, :title
  end

  def title
    "#{object.number} - #{object.name}"
  end

  def signature_date
    return 'N.I' unless object.signature_date
    I18n.l(object.signature_date)
  end

  def validity_date
    return 'N.I' unless object.validity_date
    I18n.l(object.validity_date)
  end

  def cooperative_address_city_name
    "#{object.cooperative.address_city_name} / #{object.cooperative.address_state_name}"
  end
end
