require 'rubyXL'

namespace :upload do
  desc 'Upload provider with file'
  task providers: :environment do |task|
    table_providers = Rails.root.join('lib', 'tasks', 'providers', 'files', 'Tabelas_Forncecedores.xlsx')
    workbook = RubyXL::Parser.parse table_providers
    worksheets = workbook.worksheets

    with_feedback('upload:providers_classifications') do
      load_provider_classifications(worksheets[1])
    end

    with_feedback('upload:providers') do
      providers(worksheets.first)
    end
  end

  def with_feedback(task)
    spinner = TTY::Spinner.new("[:spinner] #{task}")
    spinner.auto_spin
    begin
      yield
    rescue => e
      spinner.error("- Erro: #{e.message}")
    end

    spinner.success
  end

  def providers(worksheets)
    providers = worksheets
    providers[1..-1].each do |row|
      new_provider = new_provider(row)
      address = address_provider(row, new_provider)
      legal_representative = legal_representative(row, new_provider)
      legal_representative_address = legal_representative_address(row, legal_representative)

      new_provider.save(validate: false) unless all_nil?(new_provider)
      address.save(validate: false) unless all_nil?(address)
      legal_representative.save(validate: false) unless all_nil?(legal_representative)
      legal_representative_address.save(validate: false) unless all_nil?(legal_representative_address)

      provider_id = row.cells[0]&.value
      new_provider.classifications = Classification.where(code: @provider_classifications[provider_id]) if new_provider.persisted?
    end
  end

  def load_provider_classifications(worksheet)
    @provider_classifications = []
    worksheet[1..-1].each do |row|
      index = row.cells[2].value.to_i

      next unless index > 0

      value = row.cells[1]&.value

      @provider_classifications[index] = [] unless @provider_classifications[index].present?
      @provider_classifications[index] << value if value.present?
    end
  end

  def new_provider(row)
    document = check_null_value(row.cells[1]&.value).to_s.gsub(/[^(0-9)]/, '')

    type = document.size == 14 ? 'Company' : 'Individual'
    document = mask_document(document)

    new_provider = Provider.find_or_initialize_by(document: document)

    new_provider.name = check_null_value(row.cells[2]&.value)
    new_provider.type = type
    new_provider
  end

  def mask_document(document)
    return CPF.mask(document) if document.size == 11
    maskCnpj(document)
  end

  def address_provider(row, new_provider)
    address = Address.find_or_initialize_by(addressable: new_provider)
    address.latitude = check_null_value(row.cells[4]&.value)
    address.longitude = check_null_value(row.cells[5]&.value)
    address.address = check_null_value(row.cells[6]&.value)
    address.number = check_null_value(row.cells[7]&.value)
    address.neighborhood = check_null_value(row.cells[8]&.value)
    address.cep = check_null_value(row.cells[9]&.value)
    address.complement = check_null_value(row.cells[10]&.value)
    address.reference_point = check_null_value(row.cells[11]&.value)
    code = check_null_value(row.cells[12]&.value)
    address.city = City.find_by(code: code) if code
    address
  end

  def legal_representative(row, new_provider)
    legal_representative = LegalRepresentative.find_or_initialize_by(representable: new_provider)
    legal_representative.cpf = CPF.mask(check_null_value(row.cells[13]&.value))
    legal_representative.name = check_null_value(row.cells[14]&.value)
    legal_representative.nationality = check_null_value(row.cells[15]&.value)
    legal_representative.civil_state = check_null_value(row.cells[16]&.value)
    legal_representative.rg = check_null_value(row.cells[17]&.value)
    legal_representative
  end

  def legal_representative_address(row, legal_representative)
    legal_representative_address = Address.find_or_initialize_by(addressable: legal_representative)
    legal_representative_address.address = check_null_value(row.cells[20]&.value)
    legal_representative_address.number = check_null_value(row.cells[21]&.value)
    legal_representative_address.cep = check_null_value(row.cells[22]&.value)
    legal_representative_address.neighborhood = check_null_value(row.cells[23]&.value)
    code = check_null_value(row.cells[24]&.value)
    legal_representative_address.city = City.find_by(code: code) if code
    legal_representative_address.latitude = check_null_value(row.cells[25]&.value)
    legal_representative_address.longitude = check_null_value(row.cells[26]&.value)
    legal_representative_address.complement = check_null_value(row.cells[27]&.value)
    legal_representative_address.reference_point = check_null_value(row.cells[28]&.value)
    legal_representative_address
  end

  def maskCnpj(number)
    number.gsub(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, "\\1.\\2.\\3/\\4-\\5")
  end

  def all_nil?(obj)
    obj.attributes.except(
      'addressable_type', 'addressable_id',
      'representable_type', 'representable_id',
      'addressable_type', 'addressable_id'
      ).all?{|k, v| v.nil?}
  end

  def check_null_value(value)
    value == 'NULL' ? '' : value
  end
end
