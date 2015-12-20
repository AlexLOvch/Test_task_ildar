class CreateBusinessAccounts < ActiveRecord::Migration
  def change
    create_table :business_accounts do |t|
      t.string :name
      t.integer :customer_id
      t.timestamps null: false
    end
  end
end
