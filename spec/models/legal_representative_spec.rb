require 'rails_helper'

RSpec.describe LegalRepresentative, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:address).dependent(:destroy) }
    it { is_expected.to belong_to :representable }
  end

  describe 'enums' do
    let(:expected){ %i[single married divorced widower separated] }
    it { is_expected.to define_enum_for(:civil_state).with_values(expected) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :nationality }
    it { is_expected.to validate_presence_of :civil_state }
    it { is_expected.to validate_presence_of :rg }
    it { is_expected.to validate_presence_of :cpf }
    it { is_expected.to validate_cpf_for :cpf }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
