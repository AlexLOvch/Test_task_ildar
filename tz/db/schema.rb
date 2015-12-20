# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151219144438) do

  create_table "accounting_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "accounting_type_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "accounting_categories_devices", force: :cascade do |t|
    t.integer  "accounting_category_id"
    t.integer  "device_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "accounting_types", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "business_accounts", force: :cascade do |t|
    t.string   "name"
    t.integer  "customer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string   "number",                      null: false
    t.integer  "customer_id",                 null: false
    t.integer  "business_account_id"
    t.integer  "device_model_id"
    t.integer  "device_make_id"
    t.string   "carrier_base_id"
    t.string   "device_model_mapping_id"
    t.string   "carrier_rate_plan_id"
    t.string   "contact_id"
    t.string   "model_id"
    t.string   "model"
    t.string   "heartbeat"
    t.string   "hmac_key"
    t.string   "hash_key"
    t.string   "additional_data"
    t.string   "deferred"
    t.string   "deployed_until"
    t.string   "transfer_token"
    t.string   "username"
    t.string   "location"
    t.string   "contract_expiry_date"
    t.string   "email"
    t.string   "inactive"
    t.string   "in_suspension"
    t.string   "is_roaming"
    t.string   "imei_number"
    t.string   "sim_number"
    t.string   "employee_number"
    t.string   "additional_data_old"
    t.string   "added_features"
    t.string   "current_rate_plan"
    t.string   "data_usage_status"
    t.string   "transfer_to_personal_status"
    t.string   "apple_warranty"
    t.string   "eligibility_date"
    t.string   "number_for_forwarding"
    t.string   "call_forwarding_status"
    t.string   "asset_tag"
    t.string   "status"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end
