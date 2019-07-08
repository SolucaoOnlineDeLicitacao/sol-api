class AddCodeToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :code, :string
  end
end
