module BiddingsService::Download
  module DeliveryMethods
    private

    # do not use this array on const definition,
    # use on method, for `with_locale` to work.
    def header_delivery_columns
      [
        I18n.t('services.biddings.download.header.delivery.title'),
        I18n.t('services.biddings.download.header.delivery.columns')
      ]
    end

    def delivery_sheet
      @delivery_sheet ||= book.create_sheet(
        I18n.t('services.biddings.download.header.delivery.sheet')
      )
    end

    def row_delivery_values(lot)
      [
        lot.id,
        lot.name,
        deadline(lot),
        address(lot)
      ]
    end

    def deadline(lot)
      I18n.t('services.biddings.download.header.delivery.rows.deadline') % days_deadline(lot)
    end

    def days_deadline(lot)
      lot.deadline || lot.bidding.deadline
    end

    def address(lot)
      lot.address || lot.bidding.address
    end
    
  end
end
