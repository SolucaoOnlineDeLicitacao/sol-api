RSpec.shared_examples "concerns/password_skippable" do

  subject { build(described_class.model_name.i18n_key) }

  describe 'attr_accessor' do
    it { is_expected.to respond_to(:skip_password_validation) }
  end

  describe '#password_required?' do

    context 'when skip_password_validation' do
      before { subject.skip_password_validation! }

      it { expect(subject.send(:password_required?)).to be_falsy }
    end

    context 'when not skip_password_validation' do
      it { expect(subject.send(:password_required?)).to be_truthy }
    end
  end
end
