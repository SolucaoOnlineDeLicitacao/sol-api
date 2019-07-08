require 'rails_helper'

RSpec.describe Cooperative::Search do
  it { is_expected.to be_unaccent_searchable_like('cooperatives.name') }
  it { is_expected.to be_unaccent_searchable_like('cooperatives.cnpj') }
end
