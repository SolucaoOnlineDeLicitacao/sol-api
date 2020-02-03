require 'rails_helper'

RSpec.describe Importers::CovenantImporter do
  let!(:classification) { create(:classification, code: 1_000_000_000) }

  let!(:city) { create(:city, code: 9999999) }

  let!(:cooperative) { create(:cooperative, name: "Associação teste", cnpj: "11.080.768/0001-39") }
  let(:user) { create(:user, cooperative: cooperative, cpf: "764.918.511-76") }

  let(:admin) { create(:admin, name: 'Revisor', role: :general, email: "sdc+supervisor@caiena.net") }

  let(:covenant) do
    create(:covenant, name: "Projeto de Apoio a Cadeia Produtiva",
      number: "2018/0001", status: :waiting, signature_date: "2018-10-10",
      validity_date: "2019-10-10", estimated_cost: 6_000_000.50,
      cooperative: cooperative, admin: admin, group: false, city: city
    )
  end

  let!(:unit) { create(:unit) }
  let!(:unit_2) { create(:unit) }

  let(:item1) do
    create(:item, code: 1_000, title: "Telha metálica trapezoidal",
      description: "Fornecimento de telhas metálica trapezoidal",
      classification: classification, unit: unit)
  end

  let(:item2) do
    create(:item, code: 1_001, title: "Regador de plástico 5 Litros",
      description: "Regador de plástico capacidade 5 Litros",
      classification: classification, unit: unit)
  end

  let(:item3) do
    create(:item, code: 1_002, title: "Areia",
      description: "Areia fina para construção",
      classification: classification, unit: unit)
  end

  let(:item4) do
    create(:item, code: 1_003, title: "Regador de plástico 10 Litros",
      description: "Regador de plástico capacidade 10 Litros",
      classification: classification, unit: unit)
  end

  let(:item5) do
    create(:item, code: 1_004, title: "Mesa Inox",
      description: "Mesa Inox 2,0 x 1,5 x 0,90 m",
      classification: classification, unit: unit)
  end

  let(:group1) { group = Group.new(covenant: covenant, name: "Grupo 1"); group.save(validate: false); group }
  let(:group2) { group = Group.new(covenant: covenant, name: "Grupo 2"); group.save(validate: false); group }

  let(:group_item1) { create(:group_item, group: group1, item: item1) }
  let(:group_item2) { create(:group_item, group: group1, item: item2) }

  let(:group_item3) { create(:group_item, group: group2, item: item3) }
  let(:group_item4) { create(:group_item, group: group2, item: item4) }
  let(:group_item5) { create(:group_item, group: group2, item: item5) }

  let(:group_items) { [group_item1, group_item2, group_item3, group_item4, group_item5] }

  let(:resource) do
    {
      "name": "Projeto de Apoio a Cadeia Produtiva Fruticultura Irrigada",
      "number": "2018/0001",
      "status": "running",
      "signature_date": "2018-10-15",
      "validity_date": "2019-10-15",
      "estimated_cost": 5_000_000.50,
      "covenant_cnpj": "11080768000139",
      "city_code": 9999999,

      "admin": {
        "email": "sdc+supervisor@caiena.net",
        "name": "Revisor"
      },

      "groups": [
        {
          "name": "Grupo 1",
          "group_items": [
            {
              "code": 1_000,
              "title": "Telha metálica trapezoidal",
              "description": "Fornecimento de telhas metálica trapezoidal",
              "unit": unit.name,
              "classification": 1_000_000_000,
              "quantity": 800.50,
              "estimated_cost": 15.50
            },
            {
              "code": 1_001,
              "title": "Regador de plástico 5 Litros",
              "description": "Regador de plástico capacidade 5 Litros",
              "unit": unit.name,
              "classification": 1_000_000_000,
              "quantity": 1000.001,
              "estimated_cost": 10.50
            }
          ]
        },
        {
          "name": "Grupo 2",
          "group_items": [
           {
              "code": 1_002,
              "title": "Areia",
              "description": "Areia fina para construção",
              "unit": unit_2.name,
              "classification": 1_000_000_000,
              "quantity": 15000,
              "estimated_cost": 7.50
            },
            {
              "code": 1_003,
              "title": "Regador de plástico 10 Litros",
              "description": "Regador de plástico capacidade 10 Litros",
              "unit": unit.name,
              "classification": 1_000_000_000,
              "quantity": 500,
              "estimated_cost": 100000.00
            },
            {
              "code": 1_004,
              "title": "Mesa Inox",
              "description": "Mesa Inox 2,0 x 1,5 x 0,90 m",
              "unit": unit.name,
              "classification": 1_000_000_000,
              "quantity": 200,
              "estimated_cost": 45.00
            }
          ]
        }
      ]
    }
  end

  let(:importer) { Importers::CovenantImporter.new(resource) }

  describe '#import' do
    describe 'counts' do
      context 'when new' do
        it { expect { importer.import }.to change(Covenant, :count).by(1) }
        it { expect { importer.import }.to change(Admin, :count).by(1) }
        it { expect { importer.import }.to change(Group, :count).by(2) }
        it { expect { importer.import }.to change(GroupItem, :count).by(5) }
      end

      context 'when present' do
        before { covenant; group_items }

        it { expect { importer.import }.not_to change(Covenant, :count) }
        it { expect { importer.import }.not_to change(Admin, :count) }
        it { expect { importer.import }.not_to change(Group, :count) }
        it { expect { importer.import }.not_to change(GroupItem, :count) }
      end
    end

    describe 'data' do
      context 'when failure' do
        let(:result) { importer.import }
        let(:errors) do
          [
            I18n.t("services.importer.log.resources.covenant", value: "2018/0001"),
            [
              "Name não pode ficar em branco",
              "Group items é muito curto (mínimo: 1 caracter)"
            ].to_sentence
          ].join(': ')
        end

        before do
          resource[:groups][0][:name] = nil
          resource[:groups][0][:group_items] = []
        end

        it { expect { result }.to raise_error StandardError, errors }
      end

      context 'when success' do
        context 'when new' do
          before { importer.import }

          describe 'covenant' do
            let(:imported_covenant) { Covenant.last }

            it { expect(imported_covenant.name).to eq "Projeto de Apoio a Cadeia Produtiva Fruticultura Irrigada" }
            it { expect(imported_covenant.number).to eq "2018/0001" }
            it { expect(imported_covenant.status).to eq "running" }
            it { expect(imported_covenant.city).to eq city }
            it { expect(imported_covenant.estimated_cost).to eq 5_000_000.50 }
            it { expect(imported_covenant.signature_date).to eq Date.new(2018,10,15) }
            it { expect(imported_covenant.validity_date).to eq Date.new(2019,10,15) }

            describe 'covenant admin' do
              let(:covenant_admin) { imported_covenant.admin }

              it { expect(covenant_admin.email).to eq "sdc+supervisor@caiena.net" }
              it { expect(covenant_admin.name).to eq "Revisor" }
              it { expect(covenant_admin.reviewer?).to be_truthy }
            end

            describe 'groups' do
              let(:covenant_groups) { imported_covenant.groups }

              describe 'first group' do
                let(:first_group) { covenant_groups.first }

                it { expect(first_group.name).to eq "Grupo 1" }

                describe 'group_items' do
                  let(:imported_group_item1) { first_group.group_items.first }
                  let(:item) { imported_group_item1.item }

                  it { expect(imported_group_item1.quantity).to eq 800.50 }
                  it { expect(imported_group_item1.estimated_cost).to eq 15.50 }

                  describe 'item' do
                    it { expect(item.title).to eq "Telha metálica trapezoidal" }
                    it { expect(item.description).to eq "Fornecimento de telhas metálica trapezoidal" }
                    it { expect(item.unit).to eq unit }
                    it { expect(item.classification).to eq classification }
                  end
                end
              end

              describe 'second group' do
                let(:second_group) { covenant_groups.last }

                it { expect(second_group.name).to eq "Grupo 2" }

                describe 'group_items' do
                  let(:imported_group_item1) { second_group.group_items.first }
                  let(:item) { imported_group_item1.item }

                  it { expect(imported_group_item1.quantity).to eq 15_000 }
                  it { expect(imported_group_item1.estimated_cost).to eq 7.50 }

                  describe 'item' do
                    it { expect(item.title).to eq "Areia" }
                    it { expect(item.description).to eq "Areia fina para construção" }
                    it { expect(item.unit).to eq unit_2 }
                    it { expect(item.classification).to eq classification }
                  end
                end
              end
            end
          end
        end

        context 'when present' do
          before { covenant; group_items; importer.import }

          describe 'covenant' do
            let(:imported_covenant) { Covenant.find_by(number: "2018/0001") }

            it { expect(imported_covenant.name).to eq "Projeto de Apoio a Cadeia Produtiva Fruticultura Irrigada" }
            it { expect(imported_covenant.number).to eq "2018/0001" }
            it { expect(imported_covenant.status).to eq "running" }

            describe 'covenant admin' do
              let(:covenant_admin) { imported_covenant.admin }

              it { expect(covenant_admin.email).to eq "sdc+supervisor@caiena.net" }
              it { expect(covenant_admin.name).to eq "Revisor" }
              it { expect(covenant_admin.general?).to be_truthy }
            end

            describe 'groups' do
              let(:covenant_groups) { imported_covenant.groups }

              describe 'first group' do
                let(:first_group) { covenant_groups.first }

                it { expect(first_group.name).to eq "Grupo 1" }

                describe 'group_items' do
                  let(:imported_group_item1) { first_group.group_items.first }
                  let(:item) { imported_group_item1.item }

                  it { expect(imported_group_item1.quantity).to eq 800.50 }
                  it { expect(imported_group_item1.estimated_cost).to eq 15.50 }

                  describe 'item' do
                    it { expect(item.title).to eq "Telha metálica trapezoidal" }
                    it { expect(item.description).to eq "Fornecimento de telhas metálica trapezoidal" }
                    it { expect(item.unit).to eq unit }
                    it { expect(item.classification).to eq classification }
                  end
                end
              end

              describe 'second group' do
                let(:second_group) { covenant_groups.last }

                it { expect(second_group.name).to eq "Grupo 2" }

                describe 'group_items' do
                  let(:imported_group_item1) { second_group.group_items.first }
                  let(:item) { imported_group_item1.item }

                  it { expect(imported_group_item1.quantity).to eq 15_000 }
                  it { expect(imported_group_item1.estimated_cost).to eq 7.50 }

                  describe 'item' do
                    it { expect(item.title).to eq "Areia" }
                    it { expect(item.description).to eq "Areia fina para construção" }
                    it { expect(item.unit).to eq unit_2 }
                    it { expect(item.classification).to eq classification }
                  end
                end
              end
            end
          end
        end

        describe 'available_quantity' do
          let(:group_items) { [group_item1] }
          let(:resource) do
            {
              "name": "Projeto de Apoio a Cadeia Produtiva Fruticultura Irrigada",
              "number": "2018/0001",
              "status": "running",
              "signature_date": "2018-10-15",
              "validity_date": "2019-10-15",
              "estimated_cost": 5_000_000.50,
              "covenant_cnpj": "11080768000139",
              "city_code": 9999999,
              "admin": {
                "email": "sdc+supervisor@caiena.net",
                "name": "Revisor"
              },
              "groups": [
                {
                  "name": "Grupo 1",
                  "group_items": [
                    {
                      "code": 1_000,
                      "title": "Telha metálica trapezoidal",
                      "description": "Fornecimento de telhas metálica trapezoidal",
                      "unit": unit.name,
                      "classification": 1_000_000_000,
                      "quantity": 800,
                      "estimated_cost": 15.50,
                      "status": "invalid"
                    }
                  ]
                }
              ]
            }
          end
          let(:imported_covenant) { Covenant.find_by(number: "2018/0001") }
          let(:covenant_groups) { imported_covenant.groups }
          let(:group) { covenant_groups.first }
          let(:imported_group_item) { group.group_items.first }

          before do
            group_items.map do |group_item|
              group_item.update!(
                quantity: quantity, available_quantity: available_quantity
              )
            end
            resource[:groups][0][:group_items][0][:quantity] = resource_quantity
          end

          context 'when import quantity >= available_quantity' do
            let(:quantity) { 20.95 }
            let(:available_quantity) { 5 }
            let(:resource_quantity) { 30 }

            before { importer.import }

            it { expect(imported_group_item.quantity).to eq 30 }
            it { expect(imported_group_item.available_quantity).to eq 14.05 }
          end

          context 'when import quantity < available_quantity' do
            let(:quantity) { 30 }
            let(:available_quantity) { 15 }
            let(:resource_quantity) { 10 }

            it do
              expect { importer.import }.
                to raise_error(ActiveRecord::RecordInvalid)
            end
          end
        end
      end
    end
  end
end
