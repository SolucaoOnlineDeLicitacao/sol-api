require 'rails_helper'

RSpec.describe Report, type: :model do
  subject { build(:report) }

  describe 'factories' do
    it { is_expected.to be_valid }
  end

  describe 'enums' do
    describe '.report_type' do
      let(:expected_report_types) do
        {
          biddings: 0, contracts: 1, time: 2, items: 3, suppliers_biddings: 4,
          suppliers_contracts: 5
        }
      end

      it do
        is_expected.to define_enum_for(:report_type).
          with_values(expected_report_types)
      end
    end

    describe '.status' do
      let(:expected_status) do
        { waiting: 0, processing: 1, error: 2, success: 3 }
      end

      it do
        is_expected.to define_enum_for(:status).
          with_values(expected_status)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:admin) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:admin) }
    it { is_expected.to validate_presence_of(:report_type) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'reports.created_at' }
    it { expect(described_class.default_sort_direction).to eq :desc }
  end
end
