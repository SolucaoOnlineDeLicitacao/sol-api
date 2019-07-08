class DeviceToken < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :body, presence: true
end
