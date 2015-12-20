class BusinessAccount < ActiveRecord::Base
  belongs_to :customer
end
