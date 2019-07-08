require 'rails_helper'

RSpec.describe Bound, type: :model do
  let(:params) { { south: 0.0, west: 0.0, north: 0.0, east: 0.0 } }

  subject { described_class.new(params) }

  describe 'factory' do
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    %i[south west north east].each do |orientation|
      it { is_expected.to validate_presence_of orientation }
    end
  end
end
