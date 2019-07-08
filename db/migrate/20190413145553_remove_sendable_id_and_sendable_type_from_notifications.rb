class RemoveSendableIdAndSendableTypeFromNotifications < ActiveRecord::Migration[5.2]
  def change
    remove_reference :notifications, :sendable, polymorphic: true, index: true
  end
end
