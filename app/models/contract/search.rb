#
# Métodos e constantes de busca para Contratos
#

module Contract::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(contracts.title)) LIKE unaccent(LOWER(:search))
  }
end
