module ReportsService::Items
  class Prices::Download < ReportsService::Download::Base

    private

    def load_rows
      item_similars
      sheet_load_rows
    end

    def detailings; end

    def worksheet_name
      I18n.t('services.download.items.prices.worksheet')
    end

    def sheet_row_first
      I18n.t('services.download.items.prices.worksheet')
    end

    def sheet_titles_columns
      [
        I18n.t('services.download.items.prices.column_1'),
        I18n.t('services.download.items.prices.column_2'),
        I18n.t('services.download.items.prices.column_3'),
        I18n.t('services.download.items.prices.column_4'),
        I18n.t('services.download.items.prices.column_5'),
        I18n.t('services.download.items.prices.column_6'),
        I18n.t('services.download.items.prices.column_7'),
        I18n.t('services.download.items.prices.column_8')
      ]
    end

    def name_file
      @name_file ||= "storage/variacao_preco_itens_#{DateTime.current.strftime('%d%m%Y%H%M')}.xlsx"
    end

    def item_similars
      @row_arr = []
      GroupItem.by_proposals_accepted.sorted(:id).distinct.find_each do |group_item|
        group_item.accepted_lot_group_item_lot_proposals.distinct.find_each do |item_proposal|
          new_row(item_proposal.proposal, item_proposal)
        end
      end
    end

    def new_row(proposal, item_proposal)
      row_arr = {
        title: item_proposal.item.title, name_lot: item_proposal.lot_group_item.lot.name,
        price: format_money(item_proposal.price), bidding_title: proposal.bidding.title,
        name_provider: proposal.provider.name, document: proposal.provider.document,
        name_cooperative: proposal.bidding.cooperative.name,
        cnpj_cooperative: proposal.bidding.cooperative.cnpj
      }
      @row_arr << row_arr unless @row_arr.include?(row_arr)
    end

    def sheet_load_rows
      i = 2
      @row_arr.each do |row|
        @sheet.row(i).replace [
          row[:title], row[:name_lot],
          row[:price], row[:bidding_title], row[:name_provider],
          row[:document], row[:name_cooperative], row[:cnpj_cooperative]
        ]
        i += 1
      end
    end

  end
end
