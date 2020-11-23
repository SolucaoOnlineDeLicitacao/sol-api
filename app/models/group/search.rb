#
# Métodos e constantes de busca para Grupos
#

module Group::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(groups.name)) LIKE unaccent(LOWER(:search))
  }
end
