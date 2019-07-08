require 'rails_helper'

RSpec.describe Importers::ItemImporter do
  let!(:admin) { create(:admin) }

  let!(:classification) { create(:classification, code: 1) }
  let(:classification_2) { create(:classification, code: 2) }
  let(:unit_name) { "Kilo" }
  let!(:unit) { create(:unit, name: (unit_name || '').downcase.strip.capitalize) }
  let(:item) do
    create(:item, title: title, code: code, description: description,
      classification: classification_2)
  end

  let(:title) { "Mesa Inox 2x1,5x0,9" }
  let(:description) { "Mesa Inox 2,0 x 1,5 x 0,90 m, bancada de apoiamento com abas" }
  let(:code) { 1_000 }

  let(:resource) do
    {
      "code": code,
      "title": title,
      "description": description,
      "unit": unit_name,
      "classification": 1
    }
  end

  let(:importer) { Importers::ItemImporter.new(resource) }

  describe '#import' do

    describe 'counts' do
      context 'when new' do
        it { expect { importer.import }.to change(Item, :count).by(1) }
      end

      context 'when present' do
        before { item }
        it { expect { importer.import }.not_to change(Item, :count) }
      end
    end

    describe 'data' do
      context 'when new' do
        describe 'item' do
          before { importer.import }

          let(:imported_item) { Item.last }

          it { expect(imported_item.title).to eq title }
          it { expect(imported_item.description).to eq description }
          it { expect(imported_item.classification).to eq classification }
          it { expect(imported_item.owner).to eq admin }
          it { expect(imported_item.unit_name).to eq unit.name }
        end
      end

      context 'when present' do
        describe 'item' do
          before { item; importer.import }

          let(:imported_item) { Item.find_by(code: code) }

          it { expect(imported_item.title).to eq title }
          it { expect(imported_item.description).to eq description }
          it { expect(imported_item.classification).to eq classification }
          it { expect(imported_item.owner).not_to eq admin }
          it { expect(imported_item.unit_name).to eq unit.name }
        end
      end

      describe 'unit name' do
        context 'have spaces' do
          let!(:unit_name) { "    Kilo    " }
          before { importer.import }

          let(:imported_item) { Item.last }

          it { expect(imported_item.unit_name).to eq unit.name }
        end

        context 'have spaces and capitalize letter' do
          let!(:unit_name) { "    kiLo    " }
          before { importer.import }

          let(:imported_item) { Item.last }

          it { expect(imported_item.unit_name).to eq unit.name }
        end

        context 'have spaces, capitalize letter and downcase' do
          let!(:unit_name) { "    kiLO    " }
          before { importer.import }

          let(:imported_item) { Item.last }

          it { expect(imported_item.unit_name).to eq unit.name }
        end

      end

    end
  end

end
