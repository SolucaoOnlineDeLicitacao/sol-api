class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "storage/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
