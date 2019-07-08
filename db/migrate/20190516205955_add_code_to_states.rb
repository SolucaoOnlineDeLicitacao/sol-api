class AddCodeToStates < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :code, :integer
  end
end
