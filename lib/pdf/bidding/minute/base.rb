module Pdf::Bidding
  class Minute::Base
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
      return if bidding_not_able_to_generate?

      dictionary.each do |key, value|
        html.gsub!(key, value.to_s)
      end

      html
    end

    def dictionary
      {
        '@@cooperative.name@@' => cooperative.name,
        '@@cooperative.address.address@@' => cooperative.address.address,
        '@@cooperative.address.city.name@@' => cooperative.address.city.name,
        '@@cooperative.address.city.state.name@@' => cooperative.address.city.state.name,
        '@@cooperative.cnpj@@' => cooperative.cnpj,
        '@@cooperative.legal_representative.name@@' => cooperative.legal_representative.name,
        '@@covenant.number@@' => covenant_number(bidding.covenant.number),
        '@@bidding.title@@' => bidding.title,
        '@@bidding.description@@' => bidding.description,
        '@@bidding.closing_date@@' => format_date(bidding.closing_date),
        '@@invite.suppliers.sentence@@' => invite_suppliers_sentence,
        '@@invite.suppliers.provider_sentence@@' => invite_suppliers_provider_sentence,
        '@@bidding.lot_proposals.providers@@' => bidding_lot_proposals_providers,
        '@@bidding.proposals.sentence@@' => bidding_proposals_sentence,
        '@@bidding.proposals.accepted@@' => bidding_proposals_accepted,
        '@@bidding.comments.sentence@@' => bidding_comments_sentence,
        '@@failure_event.comment@@' => failure_event_comment,
        '@@env_covenant_resource@@' => pdf_minute_env('COVENANT_RESOURCE')
      }
    end

    def covenant_number(number)
      "#{number[0..3]}/#{number[4..5]}"
    end

    def invite_suppliers_sentence
      return if bidding.invites.blank?

      I18n.t('document.pdf.bidding.minute.invites_providers') +
      bidding.invites.inject([]) do |array, invite|
        array << provider_sentence(invite)
      end.uniq.to_sentence + '.'
    end

    def invite_suppliers_provider_sentence
      return if bidding.invites.blank?

      bidding.invites.inject([]) do |array, invite|
        array << provider_sentence(invite)
      end.uniq.to_sentence + '.'
    end

    def bidding_lot_proposals_providers
      I18n.t('document.pdf.bidding.minute.proposals_providers') +
      bidding.lot_proposals.active_and_orderly.inject([]) do |array, lot_proposal|
        array << provider_sentence(lot_proposal)
      end.uniq.to_sentence + '.'
    end

    def provider_sentence(object)
      I18n.t('document.pdf.bidding.minute.provider_sentence') %
        [object.provider.name, object.provider.document]
    end

    def bidding_proposals_sentence
      if bidding.global?
        global_text + proposals_sentence(bidding.proposals) + '.'
      else
        bidding.lots.inject(['<p>']) do |array, lot|
          array << lot_text(lot) + proposals_sentence(lot.proposals) + '.'
        end.join('</p>')
      end
    end

    def global_text
      I18n.t('document.pdf.bidding.minute.global_text') % bidding.title
    end

    def lot_text(lot)
      I18n.t('document.pdf.bidding.minute.lot_text') % [lot.position, lot.name]
    end

    def proposals_sentence(proposals)
      proposals.active_and_orderly.inject([]) do |array, proposal|
        array << proposal_line(proposal)
      end.to_sentence
    end

    def proposal_line(proposal)
      proposal_value = format_currency(proposal.price_total)
      proposal_value_prepared = prepare_currency(proposal_value)

      if valid_value_for_full_text?(proposal_value_prepared)
        proposal_text = Extenso.moeda(proposal_value_prepared)

        I18n.t('document.pdf.bidding.minute.proposal_line') %
          [proposal.provider.name, proposal_value, proposal_text]
      else
        I18n.t('document.pdf.bidding.minute.proposal_line_without_text_value') %
          [proposal.provider.name, proposal_value]
      end

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

      return I18n.t('document.pdf.bidding.minute.no_proposals') if proposal.blank?

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

    def bidding_comments_sentence
      final_comments = []

      bidding_comments.group_by { |bc| bc[:provider_name] }.each do |provider_name, comments|
        comments.sort_by! { |comment| comment[:created_at] }

        final_comments.push(
          '<p>' +
          I18n.t('document.pdf.bidding.minute.bidding_comment_text') % provider_name +
          comments.inject([]) do |array, comment|
            array << "#{comment[:text]}, #{comment[:user_name]}"
          end.to_sentence +
          '</p>'
        )
      end

      final_comments.join
    end

    def bidding_comments
      bidding.proposals.inject([]) do |array, proposal|
        array << serialize_comments(proposal, proposal.event_proposal_status_changes)
        array << serialize_comments(proposal, proposal.event_cancel_proposal_accepteds)
        array << serialize_comments(proposal, proposal.event_cancel_proposal_refuseds)
      end.flatten
    end

    def serialize_comments(proposal, proposal_events)
      proposal_events.map do |event|
        {
          provider_name: proposal.provider.name,
          user_name: event.creator.name,
          text: event.data['comment'],
          created_at: event.created_at
        }
      end
    end

    def failure_event_comment
      return if bidding.event_bidding_failures.blank?

      bidding.event_bidding_failures.first.data['comment']
    end

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def prepare_currency(value)
      value.delete(',').delete('.').delete('R$ ').to_i
    end

    def format_currency(value)
      return if value.blank?

      number_to_currency(value)
    end

    def format_date(date)
      date.strftime("%d/%m/%Y")
    end

    def template_data
      @template_data ||=
        File.read(
          Rails.root.join('lib', 'pdf', 'bidding', 'minute', 'templates', template_file_name)
        )
    end

    def pdf_minute_env(key)
      ENV["PDF_MINUTE_#{key}"]
    end

    # override
    def bidding_not_able_to_generate?; end

    # override
    def template_file_name; end
  end
end
