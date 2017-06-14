class AddUnionmemberToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :unionmember, :boolean, :default => false
  end
end
