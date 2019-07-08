require 'rails_helper'

RSpec.describe EventServices::Provider::Unblock, type: :service do
  let(:blocked) { 0 }

  it_behaves_like 'a provider access flow'
end
