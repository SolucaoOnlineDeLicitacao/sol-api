class Attachment < ApplicationRecord
  validates_presence_of :file

  mount_uploader :file, FileUploader

  belongs_to :attachable, polymorphic: true
end
