class Invite < ApplicationRecord
  versionable

  belongs_to :provider
  belongs_to :bidding

  enum status: { approved: 0, pending: 1, reproved: 2 }
end
