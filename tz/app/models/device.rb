class Device < ActiveRecord::Base
  belongs_to :customer
  has_and_belongs_to_many :accounting_categories

  def self.import_export_columns
    blacklist = %w{
      customer_id
      id
      heartbeat
      hmac_key
      hash_key
      additional_data
      model_id
      deferred
      deployed_until
      device_model_mapping_id
      transfer_token
      carrier_rate_plan_id
    }
    (Device.column_names - blacklist).reject{ |c| c =~ /_at$/ } # Reject timestamps
  end

  def cancelled?
    status == 'cancelled'
  end

  def track!(params, &block)
    yield
  end

end
