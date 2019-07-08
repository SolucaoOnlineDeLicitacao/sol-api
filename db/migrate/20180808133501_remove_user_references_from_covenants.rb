class RemoveUserReferencesFromCovenants < ActiveRecord::Migration[5.2]
  def change
    remove_reference(:covenants, :user, foreign_key: true)
    add_reference(:covenants, :admin, foreign_key: true, index: true)
  end
end
