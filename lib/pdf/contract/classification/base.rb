module Pdf::Contract::Classification
  class Base
    include Call::Methods
    include ActionView::Helpers::NumberHelper

    attr_accessor :html, :table, :template

    def initialize(*args)
      super
      @template = template_file_name
      @html = template_data
      @table = fill_table_header
    end

    def main_method
      parse_html
    end

    private

    def parse_html
      return unless contract.all_signed?

      dictionary.each do |key, value|
        html.gsub!(key, value.to_s)
      end

      html
    end

    def dictionary
      {
        '@@name_cooperative@@' => cooperative.name,
        '@@cooperative_address@@' => cooperative_address,
        '@@cooperative_legal_representative_name@@' => cooperative_legal_representative_name,
        '@@name_provider@@' => provider.name,
        '@@document_provider@@' => provider.document,
        '@@provider_address@@' => provider_address,
        '@@provider_legal_representative_name@@' => provider_legal_representative_name,
        '@@lot_name@@' => lot_name,
        '@@title_bidding@@' => bidding.title,
        '@@total_value@@' => formatted_total_value,
        '@@total_full_value@@' => total_full_value,
        '@@number_covenant@@' => bidding.covenant.number,
        '@@env_name_state@@' => pdf_contract_env('NAME_STATE'),
        '@@address_delivery@@' => address_bidding_or_lot,
        '@@deadline_contract@@' => contract.deadline - 60,
        '@@deadline_lot@@' => deadline(lot),
        '@@city_cooperative@@' => cooperative.address.city.name,
        '@@date_today@@' => I18n.l(contract.supplier_signed_at.to_date),
        '@@user_signed_at_contract@@' => I18n.l(contract.user_signed_at, format: :shorter),
        '@@name_supplier@@' => contract.supplier.name,
        '@@supplier_signed_at_contract@@' => I18n.l(contract.supplier_signed_at, format: :shorter),
        '@@items_lot@@' => fill_table,
        '@@env_contract_join@@' => pdf_contract_env('CONTRACT_JOIN'),
        '@@env_covenant_resource@@' => pdf_contract_env('COVENANT_RESOURCE'),
        '@@env_loan@@' => pdf_contract_env('LOAN'),
        '@@cooperative_state@@' => cooperative_state,
        '@@cooperative_legal_representative_cpf@@' => cooperative_legal_representative_cpf,
        '@@provider_legal_representative_cpf@@' => provider_legal_representative_cpf,
        '@@env_department_development@@' => pdf_contract_env('DEPARTMENT_DEVELOPMENT'),
        '@@env_foro@@' => pdf_contract_env('FORO'),
        '@@env_productive_program@@' => pdf_contract_env('PRODUCTIVE_PROGRAM'),
        '@@env_crea@@' => pdf_contract_env('CREA'),
        '@@env_development_action_company@@' => pdf_contract_env('DEVELOPMENT_ACTION_COMPANY'),
        '@@delivery_price@@' => delivery_price,
        '@@lot_address@@' => address_bidding_or_lot,
        '@@contract_value@@' => contract_value,
        '@@number_contract@@' => contract.title,
        '@@date_contract@@' => date_full,
        '@@items_name@@' => items_name,
        '@@cnpj_cooperative@@' => cooperative.cnpj
      }
    end

    def date_full
      @date_full ||= I18n.l(contract.created_at, format: :date_contract)
    end

    def items_name
      contract.lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
        lot_group_item_lot_proposal.item.description
      end.uniq.to_sentence
    end

    def deadline(lot)
      lot.deadline.nil? ? lot.bidding.deadline : lot.deadline
    end

    def contract_value
      value = contract.proposal.price_total
      formatted_currency(value)
    end

    def delivery_price
      formatted_currency(lot_proposal.delivery_price)
    end

    def lots_list
      contract.proposal.lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
        annex_lots(lot_group_item_lot_proposal)
      end
    end

    def annex_lots(lot_group_item_lot_proposal)
      I18n.t("document.pdf.contract.annex_lots") % [
        lot_group_item_lot_proposal.lot_proposal.lot.name,
        deadline(lot_group_item_lot_proposal.lot_proposal.lot),
        formatted_currency(lot_group_item_lot_proposal.lot_proposal.delivery_price)
      ]
    end

    def fill_table
      rows_table.each_with_index.map do |rows, index|
        table_items = "#{annexs_html[index]}<table class='table' align='center'>#{table}"
        rows(rows, index, table_items)
        table_items << "</table>"
      end.join('<br/>')
    end

    def rows(rows, index, table_items)
      if rows.is_a? Array
        rows.map{ |row| table_items << row }
      else
        table_items << rows
      end
    end

    def rows_table
      contract.proposal.lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
        fill_table_row(lot_group_item_lot_proposal)
      end
    end

    def annexs_html
      @annexs_html ||= lots_list.map{|x| "<p class='center'>#{x}</p><br/>"}.uniq
    end

    def fill_table_header
      "<tr>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.title")}</th>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.description")}</th>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.classification")}</th>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.unit")}</th>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.quantity")}</th>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.unit_price")}</th>"\
        "<th>#{I18n.t("document.pdf.contract.table.header.price")}</th>"\
      "</tr>"
    end

    def fill_table_row(lot_group_item_lot_proposal)
      "<tr>"\
        "<td>#{lot_group_item_lot_proposal.item.title}</td>"\
        "<td>#{lot_group_item_lot_proposal.item.description}</td>"\
        "<td>#{lot_group_item_lot_proposal.item.classification.name}</td>"\
        "<td>#{lot_group_item_lot_proposal.item.unit.name}</td>"\
        "<td>#{formatted_number(lot_group_item_lot_proposal.lot_group_item.quantity)}</td>"\
        "<td>#{formatted_currency(lot_group_item_lot_proposal.price)}</td>"\
        "<td>#{price_total_lot(lot_group_item_lot_proposal)}</td>"\
      "</tr>"
    end

    def formatted_currency(value)
      number_to_currency(value)
    end

    def formatted_number(value)
      number_with_delimiter(value)
    end

    def prepare_currency(value)
      value.delete(',').delete('.').delete('R$ ').to_i
    end

    # TODO: move these methods to a contract decorator
    def address_bidding_or_lot
      return bidding.address unless bidding.address.empty?
      return lots.map(&:address).to_sentence if global?

      lot.address
    end

    def cooperative_address
      full_address(cooperative.address)
    end

    def cooperative_state
      cooperative.address.state.name
    end

    def provider_address
      full_address(provider.address)
    end

    def cooperative_legal_representative_name
      legal_representative(cooperative).name
    end

    def provider_legal_representative_name
      legal_representative(provider).name
    end

    def cooperative_legal_representative_cpf
      legal_representative(cooperative).cpf
    end

    def provider_legal_representative_cpf
      legal_representative(provider).cpf
    end

    def lot_name
      return lots.map(&:name).to_sentence if global?

      lot.name
    end

    def formatted_total_value
      formatted_currency(total_value)
    end

    def price_total_lot(lot_group_item_lot_proposal)
      quantity = lot_group_item_lot_proposal.lot_group_item.quantity
      price = lot_group_item_lot_proposal.price
      formatted_currency(quantity * price)
    end

    def total_full_value
      Extenso.moeda(prepare_currency(formatted_total_value))
    end

    def total_value
      @total_value ||= contract.proposal.price_total
    end

    def lot
      @lot ||= lot_proposal.lot
    end

    def lot_proposal
      @lot_proposal ||= contract.proposal.lot_proposals.first
    end

    def lots
      @lots ||= contract.proposal.lots
    end

    def full_address(address)
      "#{address.address}, #{address_complement_number(address)}, " \
      "#{address.cep}, #{address.city.name}, #{address.state.name}"
    end

    def address_complement_number(address)
      number_complement = address.number
      number_complement << ", #{address.complement}" if address.complement.present?
      number_complement
    end

    def cooperative
      @cooperative ||= contract.user.cooperative
    end

    def provider
      @provider ||= contract.supplier.provider
    end

    def bidding
      @bidding ||= contract.bidding
    end

    def global?
      bidding.global?
    end

    def legal_representative(klass)
      klass.legal_representative
    end

    def template_data
      @template_data ||=
        File.read(
          Rails.root.join('lib', 'pdf', 'contract', 'classification', 'templates', template)
        )
    end

    def pdf_contract_env(key)
      ENV["PDF_CONTRACT_#{key}"]
    end

    def template_file_name; end
  end
end
