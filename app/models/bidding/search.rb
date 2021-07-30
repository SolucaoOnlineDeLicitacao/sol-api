#
# Métodos e constantes de busca para Licitações
#

module Bidding::Search
  extend ActiveSupport::Concern
  include Searchable

  SEARCH_EXPRESSION = %q{
    unaccent(LOWER(biddings.title)) LIKE unaccent(LOWER(:search)) OR
    unaccent(LOWER(biddings.description)) LIKE unaccent(LOWER(:search)) OR
    biddings.covenant_id IN (SELECT c.id FROM covenants c WHERE unaccent(LOWER(c.number)) LIKE unaccent(LOWER(:search)))
  }
end
