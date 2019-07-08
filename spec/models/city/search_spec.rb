require 'rails_helper'

RSpec.describe City::Search do
  it { is_expected.to be_unaccent_searchable_like('cities.name') }
end
