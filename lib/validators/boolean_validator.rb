class BooleanValidator < ActiveModel::Validations::InclusionValidator
  # sobrecarregando o validador InclusionValidator.
  # fazer no model:
  # ```ruby
  # validates attribute, inclusion: [true, false]
  # validates attributes, inclusion: { in: [true, false] }
  # ```
  #
  # é o mesmo que
  # ```ruby
  # validates_with InclusionValidator, { in: [true, false] }
  # ```
  #
  # Assim, vamos estender a classe, deixando as opções padrão!
  #
  def initialize(options = {})
    super(options.merge(in: [true, false]))
  end
end
