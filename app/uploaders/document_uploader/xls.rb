class DocumentUploader::Xls < DocumentUploader
  def allowed_extensions
    %w(xls)
  end
end
