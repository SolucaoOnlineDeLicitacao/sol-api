require 'rails_helper'

# #intialize helper class
class TestInitialize1; include Call::WithExceptionsMethods end
class TestInitialize2; include Call::WithExceptionsMethods end
class TestInitialize3; include Call::WithExceptionsMethods end

# .call helper class
class TestCall
  include Call::WithExceptionsMethods
  def main_method; say_hello end
  def say_hello; 'hello' end
end

class TestWithoutMainMethod; include Call::WithExceptionsMethods end

# .call! helper class
class TestRaisingException
  include Call::WithExceptionsMethods
  def main_method; false end
  def call_exception; RecalculateItemError end
end

class TestWithoutCallExceptionMethod
  include Call::WithExceptionsMethods
  def main_method; false end
end

class TestCallWithExceptions
  include Call::WithExceptionsMethods
  def main_method; say_hello end
  def say_hello; 'hello' end
  def call_exception; RecalculateItemError end
end

RSpec.describe Call::WithExceptionsMethods do
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

  describe '.call!' do
    context 'when it runs successfully' do
      subject { TestCallWithExceptions.call!(params) }

      it { is_expected.to be_truthy }
    end

    context 'when it runs with failures' do
      context 'and raising an exception' do
        subject { TestRaisingException.call!(params) }

        it { expect { subject }.to raise_error(RecalculateItemError) }
      end

      context 'and without main_method method' do
        subject { TestWithoutMainMethod.call!(params) }

        it { expect { subject }.to raise_error(ImplementThisMethodError) }
      end

      context 'and without call_exception method' do
        subject { TestWithoutCallExceptionMethod.call!(params) }

        it { expect { subject }.to raise_error(ImplementThisMethodError) }
      end
    end
  end
end
