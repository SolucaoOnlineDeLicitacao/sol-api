require 'rails_helper'

RSpec.describe Group::Search do
  it { is_expected.to be_unaccent_searchable_like('groups.name') }
end
