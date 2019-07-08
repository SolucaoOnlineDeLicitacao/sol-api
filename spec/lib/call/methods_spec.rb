require 'rails_helper'

# #intialize helper class
class TestInitialize1; include Call::Methods end
class TestInitialize2; include Call::Methods end
class TestInitialize3; include Call::Methods end

# .call helper class
class TestCall
  include Call::Methods
  def main_method; say_hello end
  def say_hello; 'hello' end
end

class TestWithoutMainMethod; include Call::Methods end

RSpec.describe Call::Methods do
  let(:params) { { foo: 'foo', bar: 'bar' } }

  describe '#initialize' do
    context 'when params is filled' do
      subject { TestInitialize1.new(params) }

      it { expect(subject.class.instance_methods).to include(:foo, :bar)}
      it { expect(subject.foo).to eq('foo') }
      it { expect(subject.bar).to eq('bar') }
    end

    context 'when params is nil' do
      let(:params) { nil }

      subject { TestInitialize2.new(params) }

      it { expect(subject.class.instance_methods).not_to include(:foo, :bar)}
    end

    context 'when params is blank' do
      let(:params) { { } }

      subject { TestInitialize3.new(params) }

      it { expect(subject.class.instance_methods).not_to include(:foo, :bar)}
    end
  end

  describe '.call' do
    context 'when it runs successfully' do
      subject { TestCall.call(params) }

      it { is_expected.to eq('hello') }
    end

    context 'when it runs with failures' do
      subject { TestWithoutMainMethod.call(params) }

      context 'and without main_method' do
        it { expect { subject }.to raise_error(ImplementThisMethodError) }
      end
    end
  end
end
