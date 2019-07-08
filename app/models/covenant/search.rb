#
# Métodos e constantes de busca para Convênios
#

module Covenant::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(covenants.number)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(covenants.name)) LIKE unaccent(LOWER(:search))
  }
end
