class AddSentUpdatedAtToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :proposals, :sent_updated_at, :datetime
  end
end
