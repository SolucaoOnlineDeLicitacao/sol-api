require 'rails_helper'

RSpec.describe Admin::Search do
  it { is_expected.to be_unaccent_searchable_like('admins.name') }
  it { is_expected.to be_unaccent_searchable_like('admins.email') }
end
