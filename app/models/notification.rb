class Notification < ApplicationRecord
  include Sortable
  include DataAttributable

  data_attr :body_args, :title_args, :extra_args

  belongs_to :receivable, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  scope :unreads, -> { where(read_at: nil) }

  def self.by_receivable(receiver)
    where(receivable: receiver)
  end

  def self.default_sort_column
    'notifications.created_at'
  end

  def self.default_sort_direction
    :desc
  end
end
