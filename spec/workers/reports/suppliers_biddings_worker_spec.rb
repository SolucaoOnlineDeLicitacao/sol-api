require 'rails_helper'

RSpec.describe Reports::SuppliersBiddingsWorker, type: :worker do
  let(:report) { create(:report) }
  let(:service) { ReportsService::Supplier::Biddings::Download }
  let(:service_method) { :call }
  let(:params) { [report.id] }

  include_examples 'workers/perform_with_params'
end
