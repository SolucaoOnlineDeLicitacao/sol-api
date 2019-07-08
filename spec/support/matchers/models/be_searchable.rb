#
# Matcher para models que permitem buscas (Searchable)
#

#
# be_searchable_like
# Verifica se o atributo está sendo usando na expressão do tipo 'like'
#

RSpec::Matchers.define :be_searchable_like do |expected|
  match do
    search_expression_include_expected?
  end

  failure_message do
    "expected '#{subject.name}::SEARCH_EXPRESSION' to include '#{expected_expression}'"
  end

  failure_message_when_negated do
    "expected '#{subject.name}::SEARCH_EXPRESSION' to NOT include '#{expected_expression}'"
  end

  description do
    "be searchable by #{expected} as LIKE expression"
  end

  # helpers

  def search_expression_include_expected?
    search_expression = subject::SEARCH_EXPRESSION
    search_expression.include?(expected_expression)
  end

  def expected_expression
    "LOWER(#{expected}) LIKE LOWER(:search)"
  end
end

RSpec::Matchers.define :be_unaccent_searchable_like do |expected|
  match do
    search_expression_include_expected?
  end

  failure_message do
    "expected '#{subject.name}::SEARCH_EXPRESSION' to include '#{expected_expression}'"
  end

  failure_message_when_negated do
    "expected '#{subject.name}::SEARCH_EXPRESSION' to NOT include '#{expected_expression}'"
  end

  description do
    "be searchable by #{expected} as LIKE expression"
  end

  # helpers

  def search_expression_include_expected?
    search_expression = subject::SEARCH_EXPRESSION
    search_expression.include?(expected_expression)
  end

  def expected_expression
    "unaccent(LOWER(#{expected})) LIKE unaccent(LOWER(:search))"
  end
end

#
# be_searchable_exact
# Verifica se o atributo está sendo usando na expressão exata
#


RSpec::Matchers.define :be_searchable_exact do |expected|
  match do
    search_expression_include_expected?
  end

  failure_message do
    "expected '#{subject.name}::SEARCH_EXPRESSION' to include '#{expected_expression}'"
  end

  failure_message_when_negated do
    "expected '#{subject.name}::SEARCH_EXPRESSION' to NOT include '#{expected_expression}'"
  end

  description do
    "be searchable by #{expected} as LIKE expression"
  end

  # helpers

  def search_expression_include_expected?
    search_expression = subject::SEARCH_EXPRESSION
    search_expression.include?(expected_expression)
  end

  def expected_expression
    "#{expected} = :value"
  end
end
