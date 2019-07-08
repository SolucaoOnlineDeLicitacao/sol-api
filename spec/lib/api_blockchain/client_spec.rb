require 'rails_helper'

RSpec.describe ApiBlockchain::Client, type: :model do
  subject { described_class.new }

  describe '#initialize' do
    it { expect(subject.adapter).to eq Faraday.default_adapter }
    it { expect(subject.connection).to be_nil }
  end

  describe '#request' do
    let(:payload)       { { username: 'bc-bahia' } }
    let(:jwt_token)     { JWT.encode payload, Rails.application.secrets.dig(:blockchain, :hyperledger_jwt_secret), 'HS256' }
    let(:base_path)     { Rails.application.secrets.dig(:blockchain, :hyperledger_path) }
    let(:endpoint)      {  "#{base_path}/api/Bidding" }
    let(:jwt_endpoint)  { base_path + Rails.application.secrets.dig(:blockchain, :hyperledger_jwt_auth_path) }
    let(:request)       { subject.request(verb: 'POST', endpoint: endpoint, params: { 'key': 'value' }) }

    let(:headers) do
      {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/json',
        'User-Agent'=>'Ruby'
      }
    end

    let(:jwt_headers) {
      {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImJjLWJhaGlhIn0.o50BfEg7Eb_EVs-DgeRq80PLdsmPg1d2BafTo6c-njo',
        'User-Agent'=>'Faraday v0.12.2'
      }
    }

    before do
      stub_request(:get, jwt_endpoint).with(headers: jwt_headers).
        to_return(status: 200, body: '', headers: {})

      stub_request(:post, endpoint).with(headers: headers).
        to_return(status: 200, body: { key: 'value' }.to_json, headers: {})

      request
    end

    let(:stubbed_request) do
      a_request(:post, endpoint).with(headers: headers)
    end

    it { expect(stubbed_request).to have_been_made.once }
    it { expect(request).to be_a ApiBlockchain::Response }
  end
end
