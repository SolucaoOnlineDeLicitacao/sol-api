require 'rails_helper'

RSpec.describe Reports::ItemsWorker, type: :worker do
  let(:report) { create(:report) }
  let(:service) { ReportsService::Items::Prices::Download }
  let(:service_method) { :call }
  let(:params) { [report.id] }

  include_examples 'workers/perform_with_params'
end
