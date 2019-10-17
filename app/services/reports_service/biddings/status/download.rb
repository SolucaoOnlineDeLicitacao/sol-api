module ReportsService::Biddings
  class Status::Download < ReportsService::Download::Base

    private

    def load_resources
      bidding_kinds
    end

    def load_rows
      summary
    end

    def load_row_detailings
      detailing
    end

    def summary
      i = 2

      @bidding_kinds.each do |values|
        sheet_rows_summary(values[:label], values[:data], i)
        i += 1
      end
    end

    def detailing
      i = 0
      @book.concat_row(@sheet1, i, sheet_detailing_title_columns)
      i += 1

      @bidding_kinds.each do |values|
        biddings = Bidding.send("#{values[:label]}")
        next unless biddings.present?
        biddings.each do |bidding|
          sheet_rows_detailing(bidding, i)
          i += 1
        end
      end
    end

    def sheet_rows_summary(key, value, i)
      @book.replace_row(@sheet, i, sheet_rows_summary_values(key, value))
    end

    def sheet_rows_summary_values(key, value)
      [
        I18n.t("services.download.biddings.status.#{key}"),
        value[:countable],
        format_money(value[:estimated_cost]),
        format_money(value[:price_total])
      ]
    end

    def sheet_rows_detailing(bidding, i)
      @book.replace_row(@sheet1, i, sheet_rows_detailing_values(bidding))
    end

    def sheet_rows_detailing_values(bidding)
      [
        bidding.cooperative.name,
        bidding.cooperative.address.city.name,
        bidding.title,
        bidding.description,
        I18n.t("services.download.biddings.status.kind.#{bidding.kind}"),
        I18n.t("services.download.biddings.status.modality.#{bidding.modality}"),
        I18n.t("services.download.biddings.status.#{bidding.status}"),
        I18n.l(bidding.start_date),
        I18n.l(bidding.closing_date),
        format_money(bidding.lot_group_items.map(&:group_item).sum(&:estimated_cost)),
        format_money(bidding.proposals.accepted.sum(&:price_total))
      ]
    end

    def worksheet_name
      I18n.t('services.download.biddings.status.worksheet')
    end

    def sheet_row_first
      I18n.t('services.download.biddings.status.worksheet')
    end

    def sheet_titles_columns
      [
        I18n.t('services.download.biddings.status.column_1'),
        I18n.t('services.download.biddings.status.column_2'),
        I18n.t('services.download.biddings.status.column_3'),
        I18n.t('services.download.biddings.status.column_4')
      ]
    end

    def sheet_detailing_title_columns
      [
        I18n.t('services.download.biddings.status.column_5'),
        I18n.t('services.download.biddings.status.column_6'),
        I18n.t('services.download.biddings.status.column_7'),
        I18n.t('services.download.biddings.status.column_8'),
        I18n.t('services.download.biddings.status.column_9'),
        I18n.t('services.download.biddings.status.column_10'),
        I18n.t('services.download.biddings.status.column_11'),
        I18n.t('services.download.biddings.status.column_12'),
        I18n.t('services.download.biddings.status.column_13'),
        I18n.t('services.download.biddings.status.column_14'),
        I18n.t('services.download.biddings.status.column_15')
      ]
    end

    def name_key
      'licitacao_status_'
    end

    def bidding_kinds
      @bidding_kinds = ReportsService::Bidding.call
    end
  end
end
