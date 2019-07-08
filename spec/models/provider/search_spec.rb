require 'rails_helper'

RSpec.describe Provider::Search do
  it { is_expected.to be_unaccent_searchable_like('providers.name') }
  it { is_expected.to be_unaccent_searchable_like('providers.document') }
end
