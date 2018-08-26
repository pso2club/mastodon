class CreateUnionDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :union_domains do |t|
      t.string :domain
      t.integer :account_id
      t.timestamps
    end

    add_index :union_domains, [:domain, :account_id], unique: true
  end
end
