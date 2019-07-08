require 'rails_helper'

RSpec.describe Individual, type: :model do
  describe 'STI' do
    it { expect(subject.type).to eq described_class.to_s }
    it { expect(described_class.superclass).to eq Provider }
  end
end
