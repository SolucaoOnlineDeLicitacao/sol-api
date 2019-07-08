require 'rails_helper'

RSpec.describe Classification, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:classification).optional }
    it { is_expected.to have_many :items }
    it { is_expected.to have_many(:classifications).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :code }

    context 'name and classification_id uniqueness' do
      before { build(:classification) }

      it do
        is_expected.to validate_uniqueness_of(:name)
          .scoped_to(:classification_id).case_insensitive
      end
    end

    context 'code uniqueness' do
      before { build(:classification) }

      it do
        is_expected.to validate_uniqueness_of(:code).case_insensitive
      end
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'classifications.name' }
  end

  describe 'methods' do
    let(:parent_classification) { create(:classification) }
    let(:child_classification) { create(:classification, classification: parent_classification) }
    let(:parent_and_child_name) { "#{parent_classification[:name]} / #{child_classification[:name]}" }

    describe '.text' do
      it { expect(child_classification.text).to eq "#{child_classification[:code]} - #{parent_and_child_name}" }
    end

    describe '.name' do
      it { expect(child_classification.name).to eq "#{parent_and_child_name}" }
      it { expect(parent_classification.name).to eq "#{parent_classification[:name]}" }
    end

    describe '.base_classification' do
      it { expect(child_classification.base_classification).to eq parent_classification }
      it { expect(parent_classification.base_classification).to eq parent_classification }
    end

    describe '.children_classifications' do
      let!(:child_classification_2) { create(:classification, classification: child_classification) }

      it { expect(child_classification.children_classifications).to match_array [child_classification_2] }
      it { expect(parent_classification.children_classifications).to match_array [child_classification, child_classification_2] }
      it { expect(child_classification_2.children_classifications).to be_empty }
    end

    describe '.parent_classifications' do
      let!(:parent_classification_2) { create(:classification) }
      let!(:parent_classification_3) { create(:classification) }
      let(:parent_classifications) { [parent_classification, parent_classification_2, parent_classification_3] }

      it { expect(Classification.parent_classifications).to match_array parent_classifications }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
