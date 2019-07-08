class LatitudeValidator < ActiveModel::Validations::NumericalityValidator
  # sobrecarregando o validador NumericalityValidator.
  # fazer no model:
  # ```ruby
  # validates attribute, numericality: { greater_than: 10 }
  # ```
  #
  # é o mesmo que
  # ```ruby
  # validates_with NumericalityValidator, { greater_than: 10 }
  # ```
  #
  # Assim, vamos estender a classe, deixando as opções padrão!
  # ```ruby
  # # validar manualmente seria
  # validates :lat, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  # ```
  #
  def initialize(options = {})
    super(options.merge(greater_than_or_equal_to: -90, less_than_or_equal_to: 90))
  end
end
