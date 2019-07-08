require 'rails_helper'

RSpec.describe Import::ItemWorker, type: :worker do
  let(:service) { Integration::Item::Import }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
