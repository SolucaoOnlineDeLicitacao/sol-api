class AddRefusedToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :refused_by_id, :integer
    add_column :contracts, :refused_by_type, :string
    add_column :contracts, :refused_by_at, :datetime
  end
end
