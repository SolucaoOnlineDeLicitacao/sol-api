require 'rails_helper'

RSpec.describe Bidding::Search do
  it { is_expected.to be_unaccent_searchable_like('biddings.title') }
  it { is_expected.to be_unaccent_searchable_like('biddings.description') }
end
