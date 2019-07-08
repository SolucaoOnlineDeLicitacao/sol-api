require 'rails_helper'

RSpec.describe Lot::Search do
  it { is_expected.to be_unaccent_searchable_like('lot.name') }
end
