class AddLocalToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :locale, :integer, default: 0, null: false
  end
end
