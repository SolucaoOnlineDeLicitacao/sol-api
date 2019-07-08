module Importable
  extend ActiveSupport::Concern

  included do
    enum status: { waiting: 0, processing: 1, error: 2, success: 3 }
    enum file_type: { xlsx: 0, xls: 1 }

    belongs_to :provider
    belongs_to :bidding

    validates :provider, :bidding, :status, :file, :file_type, presence: true

    mount_uploader :file, FileUploader::Sheet

    def self.active
      where(status: [:waiting, :processing])
    end
  end
end
