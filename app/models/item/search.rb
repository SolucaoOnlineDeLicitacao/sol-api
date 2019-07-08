#
# Métodos e constantes de busca para Itens
#

module Item::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(items.title)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(items.description)) LIKE unaccent(LOWER(:search))
  }
end
