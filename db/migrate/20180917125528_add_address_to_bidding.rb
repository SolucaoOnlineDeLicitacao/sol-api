class AddAddressToBidding < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :address, :string
  end
end
