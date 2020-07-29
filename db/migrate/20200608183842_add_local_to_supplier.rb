class AddLocalToSupplier < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :locale, :integer, default: 0, null: false
  end
end
