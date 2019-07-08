class AddCovenantsReferencesToGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference(:groups, :covenant, foreign_key: true)
  end
end
