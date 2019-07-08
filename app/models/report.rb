class Report < ApplicationRecord
  include ::Sortable

  belongs_to :admin

  enum report_type: {
    biddings: 0, contracts: 1, time: 2, items: 3, suppliers_biddings: 4,
    suppliers_contracts: 5
  }

  enum status: { waiting: 0, processing: 1, error: 2, success: 3 }

  validates :admin, :report_type, :status, presence: true

  def self.default_sort_column
    'reports.created_at'
  end

  def self.default_sort_direction
    :desc
  end
end
