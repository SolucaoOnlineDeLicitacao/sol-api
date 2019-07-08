class EnableUnaccentExtension < ActiveRecord::Migration[5.2]
  def change
    # ensuring postgres 'unaccent' extension
    enable_extension 'unaccent' unless extension_enabled?('unaccent')
  end
end
