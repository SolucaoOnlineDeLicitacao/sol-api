#
# Métodos e constantes de busca para Licitações
#

module Bidding::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(biddings.title)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(biddings.description)) LIKE unaccent(LOWER(:search))
  }
end
