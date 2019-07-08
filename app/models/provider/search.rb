#
# Métodos e constantes de busca para Fornecedores
#

module Provider::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(providers.name)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(providers.document)) LIKE unaccent(LOWER(:search))
  }
end
