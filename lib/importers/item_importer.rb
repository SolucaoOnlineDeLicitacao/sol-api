module Importers
  class ItemImporter

    attr_accessor :resource, :item

    def initialize(resource)
      @resource = resource
    end

    def self.import(resource)
      new(resource).import
    end

    def import
      import_resource
    end

    private

    def import_resource
      return unless resource.present?

      import_item

      @item.save!
    end

    def import_item
      @item = Item.find_or_initialize_by(code: resource[:code].to_i)
      @item.attributes = item_attributes

      # associations
      @item.classification = classification
      @item.unit = unit
      @item.owner ||= Admin.first
    end

    def item_attributes
      {
        title: squish(resource[:title]),
        description: squish(resource[:description]),
      }
    end

    # helpers

    def squish(attribute)
      (attribute || '').squish
    end

    def classification
      Classification.find_by(code: resource.fetch(:classification, nil).to_i)
    end

    def unit
      Unit.find_or_create_by(name: unit_formated)
    end

    def unit_formated
      @unit_formated ||= squish(resource.fetch(:unit, '')).downcase.strip.capitalize
    end

  end
end
