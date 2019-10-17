module ReportsService::Contracts
  class Kind::Download < ReportsService::Download::Base

    private

    def load_rows
      summary
    end

    def load_row_detailings
      detailing
    end

    def summary
      i = 2
      contracts.each do |contract|
        sheet_rows_summary(contract, i)
        i += 1
      end
    end

    def worksheet_name
      I18n.t('services.download.contracts.kind.worksheet')
    end

    def sheet_row_first
      I18n.t('services.download.contracts.kind.worksheet')
    end

    def sheet_titles_columns
      [
        I18n.t('services.download.contracts.kind.column_1'),
        I18n.t('services.download.contracts.kind.column_2'),
        I18n.t('services.download.contracts.kind.column_3')
      ]
    end

    def sheet_detailing_title_columns
      [
        I18n.t('services.download.contracts.kind.column_4'),
        I18n.t('services.download.contracts.kind.column_5'),
        I18n.t('services.download.contracts.kind.column_6'),
        I18n.t('services.download.contracts.kind.column_7'),
        I18n.t('services.download.contracts.kind.column_8'),
        I18n.t('services.download.contracts.kind.column_9'),
        I18n.t('services.download.contracts.kind.column_10'),
        I18n.t('services.download.contracts.kind.column_11')
      ]
    end

    def detailing
      i = 0
      @book.concat_row(@sheet1, i, sheet_detailing_title_columns)
      i += 1

      contracts_classification.each do |contract_class|
        contract_class[:contracts].each do |contract|
          sheet_rows_detailing(contract, contract_class, i)
          i += 1
        end
      end
    end

    def sheet_rows_summary(contract, i)
      @sheet.row(i).replace [
        contract[:label],
        contract[:data][:countable],
        format_money(contract[:data][:price_total])
      ]
    end

    def sheet_rows_detailing(contract, contract_class, i)
      @book.replace_row(@sheet1, i, sheet_rows_detailing_values(contract, contract_class))
    end

    def sheet_rows_detailing_values(contract, contract_class)
      [
        "##{contract.id}", contract_class[:classification].name,
        contract.proposal.bidding.cooperative.name,
        contract.proposal.bidding.cooperative.cnpj,
        contract.proposal.bidding.title,
        contract.proposal.provider.name,
        contract.proposal.provider.document,
        format_money(contract.price_by_proposal_accepted)
      ]
    end

    def name_key
      'classificacao_contrato_'
    end

    def contracts
      @contracts ||= ReportsService::Contract.call
    end

    def contracts_classification
      @contracts_classification ||= ReportsService::Classification.call
    end
  end
end
