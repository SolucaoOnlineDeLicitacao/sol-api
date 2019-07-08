RSpec.shared_examples "concerns/addressable" do |resource|
  let!(:resource_obj) { create(resource) }
  let!(:bounds) do 
    OpenStruct.new(
      south: south,
      west: west,
      north: north,
      east: east
    )
  end

  context 'find resource with bounds correctly' do
    let!(:north) { resource_obj.address.latitude }
    let!(:south) { resource_obj.address.latitude }
    let!(:west) { resource_obj.address.longitude }
    let!(:east) { resource_obj.address.longitude }
    
    let(:resources) { described_class.by_viewport(bounds) } 

    it { expect(resources).to match_array [resource_obj] }
  end

  context 'find resource with bounds not correctly' do
    let!(:north) { 0.0 }
    let!(:south) { 0.0 }
    let!(:west) { 0.0 }
    let!(:east) { 0.0 }
    
    let(:resources) { described_class.by_viewport(bounds) } 

    it { expect(resources).to match_array [] }
  end
end
