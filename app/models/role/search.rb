#
# Métodos e constantes de busca para Cargos
#

module Role::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(roles.title)) LIKE unaccent(LOWER(:search))
  }
end
