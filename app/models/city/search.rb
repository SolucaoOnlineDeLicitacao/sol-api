#
# Métodos e constantes de busca para Cidades
#

module City::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(cities.name)) LIKE unaccent(LOWER(:search))
  }
end
