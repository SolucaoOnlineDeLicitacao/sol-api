class CreateWorkPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :work_plans do |t|
      t.references :covenant, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
