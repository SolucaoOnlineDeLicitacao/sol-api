#
# Métodos e constantes de busca para Lotes de Licitações
#

module Lot::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(lot.name)) LIKE unaccent(LOWER(:search))
  }
end
