RSpec.shared_examples 'a version of' do |action, resource_name|
  with_versioning do
    let(:type) do
      return 'update' if action.include?('patch')

      operation = action.split("_").last
      ['block', 'unblock'].include?(operation) ? 'create' : operation
    end
    let(:event_resource?) { resource_name.include?('event') }
    let(:first_match) { resource_name.split('.').last.split("_").first }
    let(:item_type) do
      event_resource? ? first_match.camelize : resource_name.camelize
    end

    before { send(action) }

    subject { version_resource(resource_name).versions.last }

    it { expect(subject.item_type).to eq(item_type) }
    it { expect(subject.item_id).to eq(version_resource(resource_name).id) }
    it { expect(subject.event).to eq(type) }
    it { expect(subject.whodunnit).to eq(user.id.to_s) }
  end
end
