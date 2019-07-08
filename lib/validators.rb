# frozen_string_literal: true

#
# Validators
#
# Provê validadores personalizados para models
#
module Validators; end

require_dependency 'cpf'
require_dependency 'cnpj'
require_dependency 'zip_code'
require_dependency 'geo'

# auto requiring matchers
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'validators', '*_validator.rb')]
  .sort.each { |f| require_dependency f }
