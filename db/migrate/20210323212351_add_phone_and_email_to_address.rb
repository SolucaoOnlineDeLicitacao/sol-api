class AddPhoneAndEmailToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :phone, :string, default: '-', null: false
    add_column :addresses, :email, :string, default: '-'
  end
end
