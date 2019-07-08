class AddDeadlineToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :deadline, :integer
  end
end
