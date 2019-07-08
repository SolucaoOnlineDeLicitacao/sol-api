RSpec.shared_examples "concerns/importable" do
  describe 'enums' do
    describe '.status' do
      let(:expected_status) { { waiting: 0, processing: 1, error: 2, success: 3 } }

      it { is_expected.to define_enum_for(:status).with_values(expected_status) }
    end

    describe '.file_type' do
      let(:expected_status) { { xlsx: 0, xls: 1 } }

      it { is_expected.to define_enum_for(:file_type).with_values(expected_status) }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:bidding) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:bidding) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:file_type) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:waiting) { create(described_class.name.underscore, status: :waiting) }
      let!(:processing) { create(described_class.name.underscore, status: :processing) }
      let!(:error) { create(described_class.name.underscore, status: :error) }

      it { expect(described_class.active).to match_array [waiting, processing] }
    end
  end
end
