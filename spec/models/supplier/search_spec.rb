require 'rails_helper'

RSpec.describe Supplier::Search do
  it { is_expected.to be_unaccent_searchable_like('suppliers.name') }
  it { is_expected.to be_unaccent_searchable_like('suppliers.cpf') }
  it { is_expected.to be_unaccent_searchable_like('suppliers.phone') }
  it { is_expected.to be_unaccent_searchable_like('suppliers.email') }
end
