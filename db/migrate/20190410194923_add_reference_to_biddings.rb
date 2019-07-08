class AddReferenceToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :classification, foreign_key: true
  end
end
