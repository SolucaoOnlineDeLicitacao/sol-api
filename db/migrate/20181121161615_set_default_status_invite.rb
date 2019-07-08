class SetDefaultStatusInvite < ActiveRecord::Migration[5.2]
  def change
    change_column :invites, :status, :integer, default: 0
  end
end
