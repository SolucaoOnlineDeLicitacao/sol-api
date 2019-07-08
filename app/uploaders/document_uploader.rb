class DocumentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "storage/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    allowed_extensions
  end
end
