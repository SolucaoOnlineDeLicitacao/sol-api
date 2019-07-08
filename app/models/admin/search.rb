#
# Métodos e constantes de busca para Usuários Administradores
#

module Admin::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(admins.name)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(admins.email)) LIKE unaccent(LOWER(:search))
  }
end
