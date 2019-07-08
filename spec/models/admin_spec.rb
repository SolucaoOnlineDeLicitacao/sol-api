require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'factories' do
    subject { build :admin }

    it { is_expected.to be_valid }
  end

  describe 'enums' do
    let(:roles) { { viewer: 0, reviewer: 1, general: 2 } }

    it { is_expected.to define_enum_for(:role).with_values(roles) }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end

  describe 'notifiable' do
    include_examples 'concerns/notifiable'
  end

  describe 'password_skippable' do
    include_examples 'concerns/password_skippable'
  end

  describe 'associations' do
    it { is_expected.to have_many :access_tokens }
    it { is_expected.to have_many :access_grants }
    it { is_expected.to have_many(:covenants).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:contract) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'admins.name' }
  end

  describe 'methods' do
    describe 'text' do
      let(:admin) { create(:admin) }

      it { expect(admin.text).to eq "#{admin.name} / #{admin.email}" }
    end
  end

end
