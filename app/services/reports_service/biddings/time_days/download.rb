module ReportsService::Biddings
  class TimeDays::Download < ReportsService::Download::Base

    private

    def load_rows
      summary
    end

    def load_row_detailings
      detailing
    end

    def summary
      list_biddings_finnished_time
    end

    def detailing
      i = 0
      @sheet1.row(i).concat sheet_detailing_title_columns
      i += 1
      Bidding.finnished.order(title: :desc).map do |bidding|
        sheet_rows_detailing(bidding, i)
        i += 1
      end
    end

    def sheet_rows_detailing(bidding, i)
      @sheet1.row(i).replace [
        bidding.cooperative.name, bidding.cooperative.address.city.name,
        bidding.title, bidding.description,
        I18n.t("services.download.biddings.time.kind.#{bidding.kind}"),
        I18n.t("services.download.biddings.time.modality.#{bidding.modality}"),
        I18n.t("services.download.biddings.time.#{bidding.status}"),
        I18n.l(bidding.start_date), I18n.l(bidding.closing_date),
        count_days(bidding),
        format_money(bidding.proposals.accepted.sum(&:price_total))
      ]
    end

    def sheet_detailing_title_columns
      [
        I18n.t('services.download.biddings.time.column_4'),
        I18n.t('services.download.biddings.time.column_5'),
        I18n.t('services.download.biddings.time.column_6'),
        I18n.t('services.download.biddings.time.column_7'),
        I18n.t('services.download.biddings.time.column_8'),
        I18n.t('services.download.biddings.time.column_9'),
        I18n.t('services.download.biddings.time.column_10'),
        I18n.t('services.download.biddings.time.column_11'),
        I18n.t('services.download.biddings.time.column_12'),
        I18n.t('services.download.biddings.time.column_13'),
        I18n.t('services.download.biddings.time.column_14')
      ]
    end

    def worksheet_name
      I18n.t('services.download.biddings.time.worksheet')
    end

    def sheet_row_first
      I18n.t('services.download.biddings.time.worksheet')
    end

    def sheet_titles_columns
      [
        I18n.t('services.download.biddings.time.column_1'),
        I18n.t('services.download.biddings.time.column_2')
      ]
    end

    def name_file
      @name_file ||= "storage/licitacao_time_#{DateTime.current.strftime('%d%m%Y%H%M')}.xlsx"
    end

    def list_biddings_finnished_time
      i = 2
      Bidding.finnished.order(title: :desc).map do |bidding|
        @sheet.row(i).replace [bidding.title, count_days(bidding)]
        i += 1
      end
    end

    def count_days(bidding)
      I18n.t('services.download.biddings.time.days', day:
        (bidding.start_date...bidding.closing_date).count)
    end
  end
end
