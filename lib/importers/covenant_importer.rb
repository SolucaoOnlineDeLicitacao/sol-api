require './lib/importers/item_importer'

module Importers
  class CovenantImporter
    include LogImporter

    attr_accessor :resource

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
      @errors = []

      return unless resource.present?

      import_covenant

      save_resource!(@covenant)

      import_groups

    end

    def save_resource!(resource, params={})
      begin
        resource.save!
      rescue StandardError => e
        errorify(resource, params)

        raise StandardError, errors_as_sentence
      end
    end

    def covenant_number
      squish(resource[:number])
    end

    def import_covenant
      @covenant = Covenant.find_or_initialize_by(number: covenant_number)
      @covenant.attributes = covenant_attributes

      @covenant.admin = admin
      @covenant.cooperative = cooperative
      @covenant.city = city
    end

    def import_groups
      return unless resource[:groups].present?

      resource[:groups].each do |group_hash|
        group = @covenant.groups.find_or_initialize_by(name: squish(group_hash[:name]))

        import_group_items(group, group_hash[:group_items])

        save_resource!(group)
      end
    end

    def import_group_items(group, group_items)
      group_items.each do |group_item_hash|
        group_item = group.group_items.find_or_initialize_by(item: item(group_item_hash))

        group_item.quantity = group_item_hash[:quantity]
        group_item.estimated_cost = group_item_hash[:estimated_cost]

        group_item.save! if group_item.persisted?
      end
    end

    def item(attributes)
      item_importer = Importers::ItemImporter.new(attributes)
      item_importer.import
      item_importer.item
    end

    # attributes

    def covenant_attributes
      {
        name: resource[:name],
        status: covenant_status_enum,
        signature_date: resource[:signature_date],
        validity_date: resource[:validity_date],
        estimated_cost: resource[:estimated_cost]
      }
    end

    def cooperative
      cnpjs = [cooperative_cnpj, maskCnpj(cooperative_cnpj)]
      @cooperative ||= Cooperative.find_by(cnpj: cnpjs)
    end

    def city
      @city ||= City.find_by(code: resource[:city_code].to_i)
    end

    def admin
      admin_hash = resource.fetch(:admin, {})

      admin = Admin.find_or_initialize_by(email: squish(admin_hash[:email]))
      admin.name = squish(admin_hash[:name])

      # existing admins can be general and be assigned to covenants
      # without losing its role
      admin.role = :reviewer unless admin.persisted?

      admin.skip_password_validation!
      admin.save

      admin
    end

    # helpers

    def resource_klass
      'covenant'
    end

    def log_header_title
      covenant_number
    end

    def cooperative_cnpj
      squish(resource[:covenant_cnpj])
    end

    def maskCnpj(number)
      CNPJ.mask(number)
    end

    def squish(attribute)
      (attribute || '').squish
    end

    def covenant_status_enum
      covenant_status = squish(resource[:status] || '')

      return covenant_status if Covenant.statuses.keys.include? covenant_status
      :waiting
    end
  end
end
