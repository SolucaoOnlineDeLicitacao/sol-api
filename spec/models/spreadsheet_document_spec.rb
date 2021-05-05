require 'rails_helper'

RSpec.describe SpreadsheetDocument, type: :model do
  subject(:spreadsheet_document) { build(:spreadsheet_document) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:biddings) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :file }
  end
end
