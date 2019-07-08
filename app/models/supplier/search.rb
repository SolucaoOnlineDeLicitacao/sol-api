#
# Métodos e constantes de busca para Usuários de Fornecedor
#

module Supplier::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(suppliers.name)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(suppliers.cpf)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(suppliers.phone)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(suppliers.email)) LIKE unaccent(LOWER(:search))
  }
end
