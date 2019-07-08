#
# Decorator básico, utilizando SimpleDelegator.
#
# Para acessar o objeto-fonte, use #object.
#
class ApplicationDecorator < SimpleDelegator

  private

  # An easier method to access the decorated instance
  def object
    __getobj__
  end

  def human_attribute_name(*args)
    object.class.human_attribute_name(*args)
  end

  def human_enum_name(name)
    enum_value = object.public_send name
    object.class.human_enum_name name, enum_value
  end

  def translate(*args)
    I18n.t(*args)
  end
  alias t translate

  # :reek:UncommunicativeMethodName
  def localize(*args)
    I18n.l(*args)
  end
  alias l localize

end
