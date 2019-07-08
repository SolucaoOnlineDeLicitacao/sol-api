require 'rails_helper'

RSpec.describe Item::Search do
  it { is_expected.to be_unaccent_searchable_like('items.title') }
  it { is_expected.to be_unaccent_searchable_like('items.description') }
end
