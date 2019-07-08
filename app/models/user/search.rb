#
# Métodos e constantes de busca para Usuários de Associação
#

module User::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(users.name)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(users.cpf)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(users.phone)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(users.email)) LIKE unaccent(LOWER(:search))
  }
end
