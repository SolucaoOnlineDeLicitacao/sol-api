require 'rails_helper'

RSpec.describe ApiIntegration::Client, type: :model do
  subject { ApiIntegration::Client.new }

  describe '#initialize' do
    it { expect(subject.adapter).to eq Faraday.default_adapter }
    it { expect(subject.connection).to be_nil }
  end

  describe '#request' do
    let(:endpoint)      { 'http://integracao.rn.org.br/cooperatives' }
    let(:bearer)         { 's3cr3t' }
    let(:request)       { subject.request(endpoint: endpoint, token: bearer) }

    let(:headers) do
      {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>"Bearer #{bearer}",
        'User-Agent'=>'Faraday v0.12.2'
      }
    end

    before do
      stub_request(:get, endpoint).with(headers: headers).
        to_return(status: 200, body: "", headers: {})

      request
    end

    let(:stubbed_request) do
      a_request(:get, endpoint).with(headers: headers)
    end

    it { expect(stubbed_request).to have_been_made.once }
    it { expect(request).to be_a ApiIntegration::Response }

  end
end
