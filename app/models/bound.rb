class Bound
  include ActiveModel::Validations

  attr_accessor :south, :west, :north, :east

  def initialize(bounds_params)
    bounds_params.each do |bound_key, bound_value|
      instance_variable_set("@#{bound_key}".to_sym, bound_value)
    end
  end

  validates :south, :west, :north, :east, presence: true
end
