require './lib/phone_number'
require './lib/importers/log_importer'

module Importers
  class CooperativeImporter
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

      import_cooperative
      import_address
      import_legal_representative
      import_users

      save_resource!(@cooperative)
    end

    def save_resource!(resource, params={})
      begin
        resource.save!
      rescue StandardError => e
        errorify(resource, { skip_errors: :users })

        raise StandardError, errors_as_sentence
      end
    end

    def cooperative_cnpj
      @cooperative_cnpj ||= maskCnpj(squish(resource[:cnpj]))
    end

    def import_cooperative
      @cooperative = Cooperative.find_or_initialize_by(cnpj: cooperative_cnpj)
      @cooperative.name = squish(resource[:name])
    end

    def import_address
      address = @cooperative.address || @cooperative.build_address
      address.attributes = address_attributes(resource[:address])
      address.skip_integration_validations!

      save_resource!(address) if address.persisted?

      errorify(address)
    end

    def import_legal_representative
      legal_representative = @cooperative.legal_representative || @cooperative.build_legal_representative
      legal_representative.attributes = legal_representative_attributes

      errorify(legal_representative)

      legal_representative_address = legal_representative.address || legal_representative.build_address
      legal_representative_address.skip_integration_validations!
      legal_representative_address.attributes = address_attributes(resource.dig(:legal_representative, :address))

      save_resource!(legal_representative_address) if legal_representative_address.persisted?

      errorify(legal_representative_address)
    end

    def import_users
      return unless resource[:users].present?

      resource[:users].each do |user_hash|
        cpf = CPF.mask(squish(user_hash[:cpf]))

        user = @cooperative.users.find_or_initialize_by(cpf: cpf)
        user.attributes = user_attributes(user_hash)

        user.skip_password_validation!
        user.skip_integration_validations!

        save_resource!(user) if user.persisted?

        errorify(user)
      end
    end


    # attributes

    def legal_representative_attributes
      attributes = resource.fetch(:legal_representative, {})
      cpf = CPF.mask(squish(attributes[:cpf]))

      attributes.except(:address).merge(civil_state: civil_state_enum, cpf: cpf)
    end

    def address_attributes(attributes)
      return {} unless attributes.present?

      attributes[:city_id] = find_city(attributes[:city_code])&.id
      attributes[:cep] = maskCep(attributes[:cep])
      attributes.except(:city, :state, :city_code)
    end

    def user_attributes(attributes)
      return {} unless attributes.present?

      attributes[:role_id] = find_role(attributes[:role])&.id if attributes[:role].present?
      attributes[:phone] = PhoneNumber.mask(squish(attributes[:phone]))
      attributes.except(:role, :cpf)
    end

    # helpers

    def resource_klass
      'cooperative'
    end

    def log_header_title
      cooperative_cnpj
    end

    def maskCnpj(number)
      CNPJ.mask(number)
    end

    def maskCep(cep)
      ZipCode.mask(cep)
    end

    def squish(attribute)
      (attribute || '').squish
    end

    def find_role(role)
      role_title = squish(role)
      role = Role.search(role_title).first
      return role if role

      Role.create(title: role_title)
    end

    def find_city(city_code)
      City.find_by(code: city_code.to_i)
    end

    def civil_state_enum
      civil_state = squish(resource.dig(:legal_representative, :civil_state) || '')

      case civil_state[0..2].upcase
      when "SOL" then :single
      when "CAS" then :married
      when "DIV" then :divorced
      when "VIU" then :widower
      when "SEP" then :separated
      else :single
      end
    end
  end
end
