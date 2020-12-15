require 'rails_helper'
require './lib/api_integration/response'
require './lib/api_integration/client'
require './lib/importers/covenant_importer'

RSpec.describe Integration::Covenant::Import do
  let!(:configuration) { create(:integration_covenant_configuration) }
  let!(:service) { Integration::Covenant::Import.new }

  let(:fake_body) do
    [
      {
        "name": "Convênio"
      },
      {
        "name": "Convênio 2"
      }
    ]
  end

  describe 'attr_accessor' do
    it { expect(service).to respond_to :configuration }
  end

  describe 'call' do
    context 'when success request' do
      let(:request) { ApiIntegration::Response.new(status: 200, body: fake_body) }

      before do
        allow(service).to receive(:request) { request }
        allow_any_instance_of(Covenant).to receive(:save!) { true }
        allow_any_instance_of(Group).to receive(:save!) { true }
        allow_any_instance_of(Item).to receive(:save!) { true }

        allow(Importers::CovenantImporter).to receive(:import).and_call_original
        service.call
        configuration.reload
      end

      it { expect(Importers::CovenantImporter).to have_received(:import).twice }
      it { expect(configuration.status_success?).to be_truthy }
      it { expect(configuration.last_success_at).to be_present }
    end

    context 'when not success request' do
      let(:request) { ApiIntegration::Response.new(status: 302, body: { "key": "param" }) }

      before do
        allow(service).to receive(:request) { request }
        service.call
        configuration.reload
      end

      it { expect(configuration.status_fail?).to be_truthy }
      it { expect(configuration.last_success_at).to be_nil }
    end
  end

end
