require 'rails_helper'

RSpec.describe Importers::CooperativeImporter do
  let!(:state) { create(:state, uf: 'RN') }
  let!(:city) { create(:city, state: state, name: 'São José de Mipibu', code: 123456) }
  let!(:role) { create(:role, title: "Presidente") }
  let(:cooperative) { create(:cooperative, name: "Associação teste 2", cnpj: "11.080.768/0001-39") }
  let(:user) { create(:user, cooperative: cooperative, cpf: "362.656.078-39") }

  let(:resource) do
    {
      "name": "Associação teste",
      "cnpj": "11.080.768/0001-39",
      "address": {
        "latitude": -5.978518,
        "longitude": -35.256836,
        "address": "Rua exemplo",
        "number": "100",
        "neighborhood": "Centro",
        "cep": "59162-000",
        "complement": "Complemento",
        "reference_point": "Ponto de referencia",
        "city": "São José de Mipibu",
        "city_code": "123456",
        "state": "RN"
      },
      "legal_representative": {
        "name": "Nome do representante",
        "nationality": "Brasileiro",
        "civil_state": "Solteiro(a)",
        "rg": "11.222.333-4",
        "cpf": "66121558172",
        "valid_until": "25/10/2019",
        "address": {
          "latitude": -5.978518,
          "longitude": -35.256836,
          "address": "Rua exemplo 2",
          "number": "1002",
          "neighborhood": "Centro 2",
          "cep": "59162000",
          "complement": "Complemento 2",
          "reference_point": "Ponto de referencia 2",
          "city": "-",
          "city_code": "-",
          "state": "RN"
        }
      },
      "users": [
        {
          "email": "example1@example.com",
          "name": "Usuário Exemplo 1",
          "role": "Presidente",
          "cpf": "36265607839",
          "phone": "-"
        },
        {
          "email": "example2@example.com",
          "name": "Usuário Exemplo 2",
          "cpf": "686.254.564-72",
          "phone": "3545671234"
        }
      ]
    }
  end

  let(:importer) { Importers::CooperativeImporter.new(resource) }

  describe '#import' do

    describe 'counts' do
      context 'when new' do
        it { expect { importer.import }.to change(Cooperative, :count).by(1) }
        it { expect { importer.import }.to change(LegalRepresentative, :count).by(1) }
        it { expect { importer.import }.to change(Address, :count).by(2) }
        it { expect { importer.import }.to change(User, :count).by(2) }
      end

      context 'when present' do
        before { user }

        it { expect { importer.import }.not_to change(Cooperative, :count) }
        it { expect { importer.import }.not_to change(LegalRepresentative, :count) }
        it { expect { importer.import }.not_to change(Address, :count) }
        it { expect { importer.import }.to change(User, :count).by(1) }
      end
    end

    describe 'data' do
      context 'when failure' do
        let(:result) { importer.import }
        let(:errors) do
          [
            I18n.t("services.importer.log.resources.cooperative", value: "11.080.768/0001-39"),
            [
              "Name não pode ficar em branco",
              "E-mail não pode ficar em branco",
              "Nome precisa ser informado",
              "Legal representative name não pode ficar em branco"
            ].to_sentence
          ].join(': ')
        end

        before do
          resource[:name] = nil
          resource[:legal_representative][:name] = nil
          resource[:users][0][:email] = nil
        end

        it { expect { result }.to raise_error StandardError, errors }
      end

      context 'when success' do
        before { importer.import }

        context 'when new' do
          describe 'cooperative' do
            let(:imported_cooperative) { Cooperative.last }

            it { expect(imported_cooperative.name).to eq "Associação teste" }
            it { expect(imported_cooperative.cnpj).to eq "11.080.768/0001-39" }

            describe 'cooperative address' do
              let(:cooperative_address) { imported_cooperative.address }

              it { expect(cooperative_address.latitude).to eq -5.978518 }
              it { expect(cooperative_address.longitude).to eq -35.256836 }
              it { expect(cooperative_address.address).to eq "Rua exemplo" }
              it { expect(cooperative_address.number).to eq "100" }
              it { expect(cooperative_address.neighborhood).to eq "Centro" }
              it { expect(cooperative_address.cep).to eq "59162-000" }
              it { expect(cooperative_address.complement).to eq "Complemento" }
              it { expect(cooperative_address.reference_point).to eq "Ponto de referencia" }
              it { expect(cooperative_address.city).to eq city }
            end

            describe 'legal_representative' do
              let(:legal_representative) { imported_cooperative.legal_representative }

              it { expect(legal_representative.name).to eq "Nome do representante" }
              it { expect(legal_representative.nationality).to eq "Brasileiro" }
              it { expect(legal_representative.civil_state).to eq 'single' }
              it { expect(legal_representative.rg).to eq "11.222.333-4" }
              it { expect(legal_representative.cpf).to eq "661.215.581-72" }
              it { expect(legal_representative.valid_until).to eq Date.parse("25/10/2019") }

              describe 'legal_representative address' do
                let(:legal_representative_address) { legal_representative.address }

                it { expect(legal_representative_address.latitude).to eq -5.978518 }
                it { expect(legal_representative_address.longitude).to eq -35.256836 }
                it { expect(legal_representative_address.address).to eq "Rua exemplo 2" }
                it { expect(legal_representative_address.number).to eq "1002" }
                it { expect(legal_representative_address.neighborhood).to eq "Centro 2" }
                it { expect(legal_representative_address.cep).to eq "59162-000" }
                it { expect(legal_representative_address.complement).to eq "Complemento 2" }
                it { expect(legal_representative_address.reference_point).to eq "Ponto de referencia 2" }
                it { expect(legal_representative_address.city).to be_nil }
              end
            end

            describe 'users' do
              let(:cooperative_users) { imported_cooperative.users }

              describe 'first user' do
                let(:first_user) { cooperative_users.first }

                it { expect(first_user.email).to eq "example1@example.com" }
                it { expect(first_user.name).to eq "Usuário Exemplo 1" }
                it { expect(first_user.role_title).to eq "Presidente" }
                it { expect(first_user.cpf).to eq "362.656.078-39" }
                it { expect(first_user.phone).to be_nil }
              end

              describe 'first user' do
                let(:second_user) { cooperative_users.last }

                it { expect(second_user.email).to eq "example2@example.com" }
                it { expect(second_user.name).to eq "Usuário Exemplo 2" }
                it { expect(second_user.role_title).to be_nil }
                it { expect(second_user.cpf).to eq "686.254.564-72" }
                it { expect(second_user.phone).to eq "(35) 4567-1234" }
              end
            end
          end
        end

        context 'when present' do
          describe 'cooperative' do
            let(:imported_cooperative) { Cooperative.find_by(cnpj: "11.080.768/0001-39") }

            it { expect(imported_cooperative.name).to eq "Associação teste" }
            it { expect(imported_cooperative.cnpj).to eq "11.080.768/0001-39" }

            describe 'cooperative address' do
              let(:cooperative_address) { imported_cooperative.address }

              it { expect(cooperative_address.latitude).to eq -5.978518 }
              it { expect(cooperative_address.longitude).to eq -35.256836 }
              it { expect(cooperative_address.address).to eq "Rua exemplo" }
              it { expect(cooperative_address.number).to eq "100" }
              it { expect(cooperative_address.neighborhood).to eq "Centro" }
              it { expect(cooperative_address.cep).to eq "59162-000" }
              it { expect(cooperative_address.complement).to eq "Complemento" }
              it { expect(cooperative_address.reference_point).to eq "Ponto de referencia" }
              it { expect(cooperative_address.city).to eq city }
            end

            describe 'legal_representative' do
              let(:legal_representative) { imported_cooperative.legal_representative }

              it { expect(legal_representative.name).to eq "Nome do representante" }
              it { expect(legal_representative.nationality).to eq "Brasileiro" }
              it { expect(legal_representative.civil_state).to eq 'single' }
              it { expect(legal_representative.rg).to eq "11.222.333-4" }
              it { expect(legal_representative.cpf).to eq "661.215.581-72" }
              it { expect(legal_representative.valid_until).to eq Date.parse("25/10/2019") }

              describe 'legal_representative address' do
                let(:legal_representative_address) { legal_representative.address }

                it { expect(legal_representative_address.latitude).to eq -5.978518 }
                it { expect(legal_representative_address.longitude).to eq -35.256836 }
                it { expect(legal_representative_address.address).to eq "Rua exemplo 2" }
                it { expect(legal_representative_address.number).to eq "1002" }
                it { expect(legal_representative_address.neighborhood).to eq "Centro 2" }
                it { expect(legal_representative_address.cep).to eq "59162-000" }
                it { expect(legal_representative_address.complement).to eq "Complemento 2" }
                it { expect(legal_representative_address.reference_point).to eq "Ponto de referencia 2" }
                it { expect(legal_representative_address.city).to be_nil }
              end
            end

            describe 'users' do
              let(:cooperative_users) { imported_cooperative.users }

              describe 'first user' do
                let(:first_user) { cooperative_users.first }

                it { expect(first_user.email).to eq "example1@example.com" }
                it { expect(first_user.name).to eq "Usuário Exemplo 1" }
                it { expect(first_user.role_title).to eq "Presidente" }
                it { expect(first_user.cpf).to eq "362.656.078-39" }
                it { expect(first_user.phone).to be_nil }
              end

              describe 'first user' do
                let(:second_user) { cooperative_users.last }

                it { expect(second_user.email).to eq "example2@example.com" }
                it { expect(second_user.name).to eq "Usuário Exemplo 2" }
                it { expect(second_user.role_title).to be_nil }
                it { expect(second_user.cpf).to eq "686.254.564-72" }
                it { expect(second_user.phone).to eq "(35) 4567-1234" }
              end
            end
          end
        end
      end
    end
  end

end
