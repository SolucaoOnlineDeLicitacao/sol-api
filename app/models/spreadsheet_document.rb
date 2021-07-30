class SpreadsheetDocument < Document
  mount_uploader :file, DocumentUploader::Xls
end
