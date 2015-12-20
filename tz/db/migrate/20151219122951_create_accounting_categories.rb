class CreateAccountingCategories < ActiveRecord::Migration
  def change
    create_table :accounting_categories do |t|
      t.string :name
      t.integer :accounting_type_id, null: false
      t.timestamps null: false
    end
  end
end
