require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe 'constants' do
    it { expect(Provider::TYPES).to eq %i[individual company] }
  end

  describe 'associations' do
    it { is_expected.to have_one :address }
    it { is_expected.to have_one :legal_representative }
    it { is_expected.to have_many(:suppliers).dependent(:destroy) }
    it { is_expected.to have_many(:proposals).dependent(:destroy) }
    it { is_expected.to have_many(:lot_proposals).through(:proposals) }
    it { is_expected.to have_many(:attachments).dependent(:destroy) }
    it { is_expected.to have_many(:provider_classifications) }
    it { is_expected.to have_many(:classifications).through(:provider_classifications) }
    it { is_expected.to have_many(:invites).dependent(:destroy) }
    it { is_expected.to have_many(:bidding).through(:invites) }
    it { is_expected.to have_many(:contracts).through(:proposals) }
    it { is_expected.to have_many(:proposal_imports).dependent(:destroy) }
    it { is_expected.to have_many(:lot_proposal_imports).dependent(:destroy) }

    it do
      is_expected.to have_many(:event_provider_accesses).order(created_at: :desc)
        .class_name(Events::ProviderAccess).dependent(:destroy)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :document }
    it { is_expected.to validate_presence_of :type }

    context 'name and document uniqueness' do
      before { build(:cooperative) }

      it do
        is_expected.to validate_uniqueness_of(:name)
          .scoped_to(:document).case_insensitive
      end
    end

    describe 'provider_classifications minimum' do
      let(:provider) { create(:provider) }

      subject { provider }

      context 'when <= 0' do
        before do
          provider.provider_classifications.destroy_all
          provider.valid?
        end

        it { is_expected.to include_error_key_for(:provider_classifications, :too_short) }
      end

      context 'when > 0' do
        it { expect(provider.provider_classifications).to be_present }
        it { is_expected.not_to include_error_key_for(:provider_classifications, :too_short) }
      end
    end
  end

  describe 'nesteds' do
    it { is_expected.to accept_nested_attributes_for :address }
    it { is_expected.to accept_nested_attributes_for :legal_representative }
    it { is_expected.to accept_nested_attributes_for(:attachments).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for :suppliers }

    describe 'provider_classifications' do
      it { is_expected.to accept_nested_attributes_for(:provider_classifications).allow_destroy(true) }

      context 'reject_if' do
        let(:provider) { create(:provider) }
        let(:classification) { create(:classification) }
        let(:provider_classification) do
          build(:provider_classification, provider: nil,
            classification: classification)
        end

        let(:all_blank_provider_classification) do
          build(:provider_classification, provider: nil, classification: nil)
        end

        before do
          provider.provider_classifications.destroy_all
          provider.provider_classifications << provider_classification
          provider.provider_classifications << all_blank_provider_classification

          provider.save
        end

        it { expect(provider.provider_classifications.count).to eq 1 }
      end
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'providers.name' }
  end

  describe 'addressable' do
    include_examples 'concerns/addressable', :individual
  end

  describe 'methods' do
    describe '.types' do
      it { expect(Provider.types).to eq Provider::TYPES }
    end

    describe 'text' do
      let(:provider) { create(:provider) }

      it { expect(provider.text).to eq "#{provider.name} / #{provider.document}" }
    end
  end

  describe 'scopes' do
    context 'all_without_users' do
      let!(:provider_1) { create(:individual) }
      let!(:provider_2) { create(:individual) }
      let!(:user) { create(:supplier, provider: provider_2) }

      let!(:provider_without_user) { Provider.all_without_users }

      it { expect(provider_without_user).to eq [provider_1] }
    end

    context 'by_classification_ids' do
      let(:classification_1) { create(:classification, name: 'Bens') }
      let!(:classification_2) { create(:classification, name: 'Bens 2', classification: classification_1) }
      let(:provider_1) { create(:individual, classifications: [ classification_1 ]) }
      let(:provider_2) { create(:individual, classifications: [ classification_2 ]) }
      let(:provider_3) { create(:individual, :skip_validation, skip_classification: true) }

      let(:provider_1_by_classification) { Provider.by_classification_ids(provider_1.classification_ids) }
      let(:provider_2_by_classification) { Provider.by_classification_ids(provider_2.classification_ids) }
      let(:provider_3_by_classification) { Provider.by_classification_ids(provider_3.classification_ids) }

      it { expect(provider_1_by_classification).to eq [provider_1] }
      it { expect(provider_2_by_classification).to eq [provider_2] }
      it { expect(provider_3_by_classification).to eq [] }
    end

    context 'with_suppliers' do
      let(:provider_1) { create(:individual) }
      let!(:provider_2) { create(:individual) }
      let!(:user) { create(:supplier, provider: provider_1) }

      it { expect(Provider.with_suppliers).to eq [provider_1] }
    end

    context 'by_classification' do
      let(:classification_1) { create(:classification, name: 'Bens') }
      let!(:classification_2) { create(:classification, name: 'Bens 2', classification: classification_1) }
      let!(:provider_1) { create(:individual, classifications: [ classification_1, classification_2 ]) }
      let!(:provider_2) { create(:individual) }
      let(:classifications) { classification_1.children_classifications }

      it { expect(Provider.by_classification(classifications)).to eq [provider_1] }
    end

    context 'with_access' do
      let(:provider_1) { create(:individual, blocked: false) }
      let(:provider_2) { create(:individual, blocked: true) }

      it { expect(Provider.with_access).to eq [provider_1] }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
