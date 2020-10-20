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
      return load_proposals if bidding.proposals.any?

      load_lot_group_items
    end

    def load_lot_group_items
      bidding.lot_group_items.each_with_index do |lot_group_item, i|
        @book.replace_row(@sheet, i + header_rows.size + 2,
          [
            lot_group_item.lot.name,
            lot_group_item.item.title,
            lot_group_item.item.description,
            format_money(lot_group_item.group_item.estimated_cost),
            number_with_delimiter(lot_group_item.quantity),
            nil,
            nil,
            nil
          ]
        )
      end
    end

    def load_proposals
      bidding.proposals.each do |proposal|
        proposal.lot_group_item_lot_proposals.each_with_index do |lgi_lp, i|
          lot_group_item = lgi_lp.lot_group_item
          @book.replace_row(@sheet, i + header_rows.size + 2,
            [
              lot_group_item.lot.name,
              lot_group_item.item.title,
              lot_group_item.item.description,
              format_money(lot_group_item.group_item.estimated_cost),
              number_with_delimiter(lot_group_item.quantity),
              format_money(lgi_lp.price),
              format_money(proposal.price_total),
              proposal.provider.name
            ]
          )
        end
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
