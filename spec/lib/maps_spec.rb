require 'rails_helper'
require './lib/maps'

RSpec.describe Maps, type: :service do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }

  let(:service) { described_class.new({resource: cooperative, collection_klass: ::Provider }) }

  describe '#initialize' do
    it { expect(service.resource).to eq cooperative }
    it { expect(service.collection_klass).to eq ::Provider }
  end

  describe '#to_json' do
    let!(:results) { [expected_markers_cooperative] }

    let(:json) { service.to_json }
    let(:expected_markers_cooperative) do
      {
        id: cooperative.id,
        type: 'cooperative',
        position: {
          lat: cooperative.address.latitude.to_f,
          lng: cooperative.address.longitude.to_f
        },
        text: cooperative.name,
        title: cooperative.name
      }.as_json
    end

    before do
      Provider.all.each do |provider|
        result =
          {
            id: provider.id,
            type: 'provider',
            position: {
              lat: provider.address.latitude.to_f,
              lng: provider.address.longitude.to_f
            },
            text: provider.name,
            title: provider.name
          }.as_json

        results << result
      end
    end

    it { expect(json[:markers][0]).to eq expected_markers_cooperative }
    it { expect(json[:markers]).to match_array results }
  end
end
