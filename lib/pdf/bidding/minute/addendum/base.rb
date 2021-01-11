module Pdf::Bidding::Minute
  class Addendum::Base
    include Call::Methods
    include ActionView::Helpers::NumberHelper
    include Pdf::HelperMethods

    attr_accessor :html

    def initialize(*args)
      super
      @html = template_data
    end

    def main_method
      parse_html
    end

    private

    def parse_html
      return if contract_not_able_to_generate?

      dictionary.each do |key, value|
        html.gsub!(key, value.to_s)
      end

      html
    end

    def dictionary
      {
        '@@contract.status.text@@' => contract_status_text,
        '@@cooperative.legal_representative.name@@' => cooperative.legal_representative.name,
        '@@bidding.proposals.accepted@@' => bidding_proposals_accepted,
        '@@cooperative.name@@' => cooperative.name,
        '@@current_date@@' => format_date(Date.current)
      }
    end

    def contract_not_able_to_generate?
      ! (contract.refused? || contract.total_inexecution?)
    end

    def contract_status_text
      return contract_refused_text if contract.refused?

      contract_total_inexecution_text
    end

    def contract_refused_text
      I18n.t('document.pdf.bidding.minute.contract_refused') %
        [contract.id, provider.name, refused_reasons]
    end

    def contract_total_inexecution_text
      I18n.t('document.pdf.bidding.minute.contract_total_inexecution') %
        [contract.id, provider.name, provider.document, cooperative.name]
    end

    def refused_reasons
      contract.event_contract_refuseds.inject([]) do |array, event|
        array << event.data['comment']
      end.to_sentence
    end

    def bidding_proposals_accepted
      if bidding.global?
        global_text + proposal_accepted(bidding.proposals)
      else
        bidding.lots.inject(['<p>']) do |array, lot|
          array << lot_text(lot) + proposal_accepted(lot.proposals)
        end.join('</p>')
      end
    end

    def proposal_accepted(proposals)
      proposal = proposals.where(status: :accepted).first

      return "" if proposal.blank?

      proposal_value = format_currency(proposal.price_total)
      proposal_value_prepared = prepare_currency(proposal_value)

      if valid_value_for_full_text?(proposal_value_prepared)
        proposal_text = Extenso.moeda(proposal_value_prepared)

        I18n.t('document.pdf.bidding.minute.proposals_accepted') %
          [proposal.provider.name, proposal.provider.document, proposal_value, proposal_text]
      else
        I18n.t('document.pdf.bidding.minute.proposals_accepted_without_text_value') %
          [proposal.provider.name, proposal.provider.document, proposal_value]
      end
    end

    def global_text
      I18n.t('document.pdf.bidding.minute.global_text') % bidding.title
    end

    def lot_text(lot)
      I18n.t('document.pdf.bidding.minute.lot_text') % [lot.position, lot.name]
    end

    def bidding
      @bidding ||= contract.bidding
    end

    def provider
      @provider ||= contract.refused? ? contract.refused_by.provider : contract.supplier.provider
    end

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def format_date(date)
      date.strftime("%d/%m/%Y")
    end

    def format_currency(value)
      return if value.blank?

      number_to_currency(value)
    end

    def prepare_currency(value)
      value.delete(',').delete('.').delete('R$ ').to_i
    end

    def template_data
      @template_data ||=
        File.read(
          Rails.root.join('lib', 'pdf', 'bidding', 'minute', 'addendum', 'templates', template_file_name)
        )
    end

    # override
    def template_file_name; end
  end
end
