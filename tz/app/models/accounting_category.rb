class AccountingCategory < ActiveRecord::Base
  belongs_to :accounting_category
  has_and_belongs_to_many :devices
end
