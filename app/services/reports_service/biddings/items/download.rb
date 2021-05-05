module ReportsService::Biddings
  class Items::Download < ReportsService::Download::Base
    include ActionView::Helpers::NumberHelper

    private

    def download
      @book = Spreadsheet::Write::Xls.new
      @sheet = @book.create_sheet(
        I18n.t('services.download.biddings.items.worksheet')
      )

      load_headers
      load_and_fill_rows

      @book.write name_file
    end

    def load_headers
      header_rows.each_with_index do |row, i|
        @book.replace_row(@sheet, i, row)
      end

      @book.replace_row(@sheet, header_rows.size + 1, header_columns)
    end

    def load_and_fill_rows
      bidding.lot_group_items.each_with_index do |lot_group_item, i|
        lot_group_item_lot_proposal =
          lot_group_item.lot_group_item_lot_proposals.first_proposal_accepted

        end_columns = if lot_group_item_lot_proposal.present?
                        proposal = lot_group_item_lot_proposal.proposal
                        [
                          format_money(lot_group_item_lot_proposal.price),
                          format_money(proposal.price_total),
                          proposal.provider.name
                        ]
                      else
                        [nil, nil, nil]
                      end

        @book.replace_row(@sheet, i + header_rows.size + 2,
          [
            lot_group_item.lot.name,
            lot_group_item.item.title,
            lot_group_item.item.description,
            format_money(lot_group_item.group_item.estimated_cost),
            number_with_delimiter(lot_group_item.quantity),
          ] + end_columns
        )
      end
    end

    def header_columns
      @header_columns ||= begin
        8.times.inject([]) do |array, i|
          array << I18n.t("services.download.biddings.items.column_#{i+1}")
        end
      end
    end

    def header_rows
      @header_rows ||= begin
        header_descriptions.each_with_index.map do |header_description, i|
          [header_description, header_values[i]]
        end
      end
    end

    def header_descriptions
      @header_descriptions ||= begin
        5.times.inject([]) do |array, i|
          array << I18n.t("services.download.biddings.items.header_row_#{i+1}")
        end
      end
    end

    def header_values
      @header_values ||= begin
        [
          "#{bidding.title} - #{bidding.description}",
          bidding.cooperative.name,
          "#{bidding.covenant.number} - #{bidding.covenant.name}",
          I18n.t("services.download.biddings.items.kind.#{bidding.kind}"),
          bidding.deadline
        ]
      end
    end

    def name_key
      'licitacao_items_'
    end
  end
end
