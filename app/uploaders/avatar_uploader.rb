class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "storage/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    '/default_avatar.jpg'
  end

  process resize_to_fill: [60, 60]

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def size_range
    1..5.megabytes
  end
end
