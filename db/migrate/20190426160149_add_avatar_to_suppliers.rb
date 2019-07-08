class AddAvatarToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :avatar, :string
  end
end
