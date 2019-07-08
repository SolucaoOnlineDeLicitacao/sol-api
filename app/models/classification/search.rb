#
# Métodos e constantes de busca para Classificações
#

module Classification::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(classifications.name)) LIKE unaccent(LOWER(:search))
  }
end
