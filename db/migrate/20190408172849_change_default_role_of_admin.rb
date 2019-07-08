class ChangeDefaultRoleOfAdmin < ActiveRecord::Migration[5.2]
  def change
    change_column_default :admins, :role, 2
  end
end
