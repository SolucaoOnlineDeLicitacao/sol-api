class DocumentUploader::Pdf < DocumentUploader
  def allowed_extensions
    %w(pdf)
  end
end
