require 'rails_helper'

RSpec.describe Role::Search do
  it { is_expected.to be_unaccent_searchable_like('roles.title') }
end
