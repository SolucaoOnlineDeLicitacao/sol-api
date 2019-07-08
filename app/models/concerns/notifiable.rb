module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :receivable
  end
end
