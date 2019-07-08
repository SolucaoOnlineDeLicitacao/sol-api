class ChangeStatusDefaultFromContract < ActiveRecord::Migration[5.2]
  def change
    change_column_default :contracts, :status, 0
  end
end
