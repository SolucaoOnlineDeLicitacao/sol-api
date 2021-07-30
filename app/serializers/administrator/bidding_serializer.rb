module Administrator
  class BiddingSerializer < ActiveModel::Serializer
    include BiddingSerializable

    attributes :spreadsheet_report

    def spreadsheet_report
      object.spreadsheet_report.try(:file).try(:url)
    end
  end
end
