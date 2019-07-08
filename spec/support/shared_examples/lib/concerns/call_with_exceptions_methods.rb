RSpec.shared_examples "Call::WithExceptionsMethods" do |call_exception|

  context 'when success call' do
    before do
      allow_any_instance_of(described_class).to receive(:call).and_return(true)
    end

    it { expect(described_class.call!).to eq true }
  end

  context 'when failure call' do
    before do
      allow_any_instance_of(described_class).to receive(:call).and_return(false)
    end

    it { expect { described_class.call! }.to raise_error(call_exception) }
  end
end
