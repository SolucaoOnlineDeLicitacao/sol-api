require 'rails_helper'

RSpec.describe EventServices::Provider::Block, type: :service do
  let(:blocked) { 1 }

  it_behaves_like 'a provider access flow'
end
