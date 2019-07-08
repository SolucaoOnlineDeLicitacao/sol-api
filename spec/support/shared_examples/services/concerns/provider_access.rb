RSpec.shared_examples 'a provider access flow' do
  let(:user) { create(:admin) }
  let(:provider) { create(:provider) }
  let(:comment) { 'a comment' }
  let(:params) { { provider: provider, comment: comment, creator: user } }
  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.provider).to eq provider }
    it { expect(subject.comment).to eq comment }
    it { expect(subject.creator).to eq user }
  end

  describe '.call' do
    before { subject }

    subject { service.call }

    context 'when return success' do
      it { is_expected.to be_truthy }
      it { expect(service.event).to be_persisted }
      it { expect(service.event.data['blocked']).to eq blocked }
    end

    context 'when failure' do
      let(:params) { { provider: provider, creator: user } }
      let(:error_event_key) { [:comment] }

      it { is_expected.to be_falsey }
      it { expect(service.event).not_to be_persisted }
      it { expect(service.event.errors.messages.keys).to eq error_event_key }
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
