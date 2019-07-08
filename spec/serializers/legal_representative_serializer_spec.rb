require 'rails_helper'

RSpec.describe LegalRepresentativeSerializer, type: :serializer do
  let(:object) { create :legal_representative }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'nationality' => object.nationality }
    it { is_expected.to include 'civil_state' => object.civil_state }
    it { is_expected.to include 'rg' => object.rg }
    it { is_expected.to include 'cpf' => object.cpf }

    describe 'valid_until' do
      context 'when present' do
        before { object.valid_until = Date.today; object.save }

        it { is_expected.to include 'valid_until' => I18n.l(Date.today) }
      end

      context 'when not present' do
        before { object.valid_until = nil; object.save }

        it { is_expected.to include 'valid_until' => 'N.I' }
      end
    end
  end
end
