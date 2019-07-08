class DropWorkPlans < ActiveRecord::Migration[5.2]
  def change
    drop_table :work_plans
  end
end
