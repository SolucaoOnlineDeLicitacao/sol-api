class AddPhoneAndCPFToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone, :string
    add_column :users, :cpf, :string
  end
end
