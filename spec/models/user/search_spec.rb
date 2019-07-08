require 'rails_helper'

RSpec.describe User::Search do
  it { is_expected.to be_unaccent_searchable_like('users.name') }
  it { is_expected.to be_unaccent_searchable_like('users.cpf') }
  it { is_expected.to be_unaccent_searchable_like('users.phone') }
  it { is_expected.to be_unaccent_searchable_like('users.email') }
end
