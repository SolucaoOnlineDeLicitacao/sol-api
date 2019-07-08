#
# Adds versioning behavior to records.
#
# Currently relying on PaperTrail gem.
#
# It should be included in ApplicationRecord and, in each versionable model,
# you must call
# ```
# class User < ApplicationRecord
#   versionable **options  # `has_paper_trail` options
# end
# ```
#
#
# You can find out versionable models with `Versionable.models` - an array of classes.
#
module Versionable
  extend ActiveSupport::Concern

  VERSIONABLE_OPTIONS = {
    class_name: 'Version',
    meta: { class_name: ->(record) { record.model_name.to_s } }
  }

  class_methods do
    def versionable(**options)
      Versionable.models << self unless Versionable.models.include? self

      has_paper_trail options.deep_merge(VERSIONABLE_OPTIONS)
    end
  end

  def self.models
    @models ||= []
  end

end
