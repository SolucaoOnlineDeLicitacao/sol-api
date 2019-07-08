require 'rails_helper'

RSpec.describe User, type: :model do
  context 'factories' do
    subject { build :user }

    it { is_expected.to be_valid }
  end

  describe 'notifiable' do
    include_examples 'concerns/notifiable'
  end

  describe 'password_skippable' do
    include_examples 'concerns/password_skippable'
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end

  describe 'associations' do
    it { is_expected.to have_many(:access_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:access_grants).dependent(:destroy) }
    it { is_expected.to have_many(:device_tokens).dependent(:destroy) }

    it { is_expected.to belong_to :cooperative }
    it { is_expected.to belong_to(:role).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :cpf }

    xcontext 'when skip_integration_validations' do
      before { subject.skip_integration_validations! }

      it { is_expected.not_to validate_phone_for(:phone) }
    end

    xcontext 'when not skip_integration_validations' do
      it { is_expected.to validate_phone_for(:phone) }
    end

    it { is_expected.to validate_cpf_for(:cpf) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:title).to(:role).with_prefix }
    it { is_expected.to delegate_method(:id).to(:role).with_prefix }
    it { is_expected.to delegate_method(:name).to(:cooperative).with_prefix }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'users.name' }
  end

  describe 'methods' do
    describe 'text' do
      let(:user) { create(:user) }

      it { expect(user.text).to eq "#{user.name} / #{user.email}" }
    end
  end
end
