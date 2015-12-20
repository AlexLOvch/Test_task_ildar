class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :number, null: false
      t.integer :customer_id, null: false
      t.integer :business_account_id
      t.integer :device_model_id
      t.integer :device_make_id
      t.string :carrier_base_id
      t.string :device_model_mapping_id
      t.string :carrier_rate_plan_id
      t.string :contact_id
      t.string :model_id
      t.string :model
      t.string :heartbeat
      t.string :hmac_key
      t.string :hash_key
      t.string :additional_data
      t.string :deferred
      t.string :deployed_until
      t.string :transfer_token
      t.string :username
      t.string :location
      t.string :contract_expiry_date
      t.string :email
      t.string :inactive
      t.string :in_suspension
      t.string :is_roaming
      t.string :imei_number
      t.string :sim_number
      t.string :employee_number
      t.string :additional_data_old
      t.string :added_features
      t.string :current_rate_plan
      t.string :data_usage_status
      t.string :transfer_to_personal_status
      t.string :apple_warranty
      t.string :eligibility_date
      t.string :number_for_forwarding
      t.string :call_forwarding_status
      t.string :asset_tag
      t.string :status
      t.timestamps null: false
    end

    create_table :accounting_categories_devices do |t|
      t.integer :accounting_category_id
      t.integer :device_id
      t.timestamps null: false
    end
  end
end
