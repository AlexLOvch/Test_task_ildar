class CreateAccountingTypes < ActiveRecord::Migration
  def change
    create_table :accounting_types do |t|
      t.integer :customer_id
      t.string :name
      t.timestamps null: false
    end
  end
end
