class RemoveWorkPlanReferencesFromGroups < ActiveRecord::Migration[5.2]
  def change
    remove_reference(:groups, :work_plan, foreign_key: true)
  end
end
