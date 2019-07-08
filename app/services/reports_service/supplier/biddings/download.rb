module ReportsService::Supplier
  class Biddings::Download < ReportsService::Download::Base

    private

    def load_resources
      provider_all
    end

    def load_rows
      summary
    end

    def load_row_detailings
      detailing
    end

    def worksheet_name
      I18n.t('services.download.supplier.biddings.worksheet')
    end

    def sheet_row_first
      I18n.t('services.download.supplier.biddings.worksheet')
    end

    def sheet_titles_columns
      [
        I18n.t('services.download.supplier.biddings.column_1'),
        I18n.t('services.download.supplier.biddings.column_2'),
        I18n.t('services.download.supplier.biddings.column_3')
      ]
    end

    def name_file
      @name_file ||= "storage/fornecedores_licitacao_#{DateTime.current.strftime('%d%m%Y%H%M')}.xlsx"
    end

    def summary
      i = 2
      suppliers_biddings.each do |provider|
        @sheet.row(i).replace [provider[:document], provider[:name], provider[:count]]
        i += 1
      end
    end

    def detailing
      i = 0
      @sheet1.row(i).concat sheet_detailing_title_columns
      i += 1
      @providers.each do |provider|
        biddings = bidding_by_provider(provider)
        next unless biddings.present?
        biddings.each do |bidding|
          sheet_rows_detailing(bidding, provider, i)
          i += 1
        end
      end
    end

    def sheet_rows_detailing(bidding, provider, i)
      @sheet1.row(i).replace [
        bidding.title, provider.name, provider.document, provider.address.city.name,
        bidding.cooperative.name, bidding.cooperative.cnpj, bidding.cooperative.address.city.name,
        I18n.t("services.download.supplier.biddings.kind.#{bidding.kind}"),
        I18n.t("services.download.supplier.biddings.modality.#{bidding.modality}"),
        I18n.t("services.download.supplier.biddings.#{bidding.status}"),
        I18n.l(bidding.start_date), I18n.l(bidding.closing_date)
      ]
    end

    def sheet_detailing_title_columns
      [
        I18n.t('services.download.supplier.biddings.column_4'),
        I18n.t('services.download.supplier.biddings.column_5'),
        I18n.t('services.download.supplier.biddings.column_6'),
        I18n.t('services.download.supplier.biddings.column_7'),
        I18n.t('services.download.supplier.biddings.column_8'),
        I18n.t('services.download.supplier.biddings.column_9'),
        I18n.t('services.download.supplier.biddings.column_10'),
        I18n.t('services.download.supplier.biddings.column_11'),
        I18n.t('services.download.supplier.biddings.column_12'),
        I18n.t('services.download.supplier.biddings.column_13'),
        I18n.t('services.download.supplier.biddings.column_14'),
        I18n.t('services.download.supplier.biddings.column_15')
      ]
    end

    def suppliers_biddings
      provider = @providers.inject([]) do |array, provider|
        fields = provider_fields(provider)
        array << fields if fields[:count] > 0
        array
      end
      provider.sort_by { |hsh| -hsh[:count] }
    end

    def provider_all
      @providers = Provider.all
    end

    def provider_fields(provider)
      {count: bidding_by_provider_count(provider), name: provider.name, document: provider.document}
    end

    def bidding_by_provider_count(provider)
      biddings_provider(provider).count
    end

    def bidding_by_provider(provider)
      biddings_provider(provider)
    end

    def biddings_provider(provider)
      Bidding.joins(:proposals).where(proposals: { provider_id: provider.id }).order(:id).uniq
    end

  end
end
