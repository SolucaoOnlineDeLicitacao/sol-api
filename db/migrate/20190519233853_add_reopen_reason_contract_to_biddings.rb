class AddReopenReasonContractToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :reopen_reason_contract, index: true, foreign_key: {to_table: :contracts}
  end
end
