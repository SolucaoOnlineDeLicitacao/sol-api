Dir["#{Rails.root}/app/uploaders/*.rb"].each { |file| require file }
if defined?(CarrierWave)
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?

    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/storage/cache"
      end

      def store_dir
        "#{Rails.root}/spec/support/storage/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
end