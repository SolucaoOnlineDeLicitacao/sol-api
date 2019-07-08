#
# Métodos e constantes de busca para Associações
#

module Cooperative::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(cooperatives.name)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(cooperatives.cnpj)) LIKE unaccent(LOWER(:search))
  }
end
