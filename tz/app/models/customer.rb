class Customer < ActiveRecord::Base
  has_many :devices
  has_many :business_accounts
  has_many :accounting_types
end
