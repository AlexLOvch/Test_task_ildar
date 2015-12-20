class AccountingType < ActiveRecord::Base
  has_many :accounting_categories
end
