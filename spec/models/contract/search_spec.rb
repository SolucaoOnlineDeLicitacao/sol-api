require 'rails_helper'

RSpec.describe Contract::Search do
  it { is_expected.to be_unaccent_searchable_like('contracts.title') }
end
