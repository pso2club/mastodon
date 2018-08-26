class AddBotToUnionDomain < ActiveRecord::Migration[5.1]
  def change
    add_column :union_domains, :bot, :boolean, :default => false
  end
end
