class AddBlockedToProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :blocked, :bool, null: false, default: false
  end
end
