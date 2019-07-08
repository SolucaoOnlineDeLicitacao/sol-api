class AddClassificationReferencesToItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :items, :classification, foreign_key: true
  end
end
