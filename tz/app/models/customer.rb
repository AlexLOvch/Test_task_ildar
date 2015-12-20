class Customer < ActiveRecord::Base
  has_many :devices
  has_many :business_accounts
  has_many :accounting_types

  def lookup_accounting_category
    lookups = {}
    accounting_types.each do |at|
      lookups["accounting_categories[#{at.name}]"] = Hash[Hash[at.accounting_categories.pluck(:name, :id)].map{ |k,v| [k.strip, v] }]
    end
    lookups
  end
end
