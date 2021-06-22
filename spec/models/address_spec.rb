require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'associations' do
    context 'when skip_integration_validations' do
      before { subject.skip_integration_validations! }

      it { is_expected.to belong_to(:city).optional }
    end

    # https://github.com/thoughtbot/shoulda-matchers/issues/1066
    context 'when not skip_integration_validations', skip: 'shoulda bug' do
      it { is_expected.to belong_to(:city) }
    end

    it { is_expected.to belong_to :addressable }
    it { is_expected.to have_one(:state).through(:city) }
  end

  describe 'validations' do
    context 'when skip_integration_validations' do
      before { subject.skip_integration_validations! }

      it { is_expected.not_to validate_zip_code_for :cep }
      it { is_expected.not_to validate_latitude_for :latitude }
      it { is_expected.not_to validate_longitude_for :longitude }
      it { is_expected.not_to validate_presence_of :cep }
      it { is_expected.not_to validate_presence_of :latitude }
      it { is_expected.not_to validate_presence_of :longitude }
    end

    context 'when not skip_integration_validations' do
      it { is_expected.to validate_presence_of :latitude }
      it { is_expected.to validate_presence_of :longitude }
      it { is_expected.to validate_presence_of :address }
      it { is_expected.to validate_presence_of :number }
      it { is_expected.to validate_presence_of :neighborhood }
      it { is_expected.to validate_presence_of :cep }
      it { is_expected.to validate_presence_of :reference_point }

      it { is_expected.to validate_zip_code_for :cep }
      it { is_expected.to validate_latitude_for :latitude }
      it { is_expected.to validate_longitude_for :longitude }
    end
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:name).to(:city).with_prefix }
    it { is_expected.to delegate_method(:name).to(:state).with_prefix }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
