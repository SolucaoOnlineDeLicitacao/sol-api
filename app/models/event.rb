class Event < ApplicationRecord
  include DataAttributable

  versionable

  belongs_to :eventable, polymorphic: true
  belongs_to :creator, polymorphic: true
end
