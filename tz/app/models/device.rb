class Device < ActiveRecord::Base
  belongs_to :customer
  has_and_belongs_to_many :accounting_categories

  validates :number, length: { minimum: 5 }

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
    }                                      #faster then reqexp
    (column_names - blacklist).reject{ |c| c.ends_with?('_at') } # Reject timestamps
  end


  def self.lookup_relation_ids_by_customer(customer)
    lookups = {}
    import_export_columns.select{|col| col.ends_with?('_id')}.each do |col|
      case col
      when 'device_make_id'  then lookups[col] = Hash[DeviceMake.pluck(:name, :id)]
      when 'device_model_id' then lookups[col] = Hash[DeviceModel.pluck(:name, :id)]
      else
        reflections.each do |k, reflection|
          if reflection.foreign_key == col
            method = reflection.plural_name.to_sym
            if customer.respond_to?(method)
              accessor = reflection.klass.respond_to?(:export_key) ? reflection.klass.send(:export_key) : 'name'
              lookups[col] = Hash[customer.send(method).pluck(accessor, :id)]
            end
          end
        end
      end
    end
    lookups
  end


  def self.invalid_accounting_types_in_csv(contents, lookups)
    errors = {}
    row = CSV.parse_line(contents, headers: true, encoding: 'UTF-8')
    row.headers.each do |header|
      if header =~ /accounting_categories\[([^\]]+)\]/ and !lookups.key?(header)
        errors['General'] = ["'#{$1}' is not a valid accounting type"]
        break
      end
    end
    errors
  end


  def self.parse_csv(contents, lookups)
    data = {}
    errors = {}
    begin
      CSV.parse(contents, headers: true, encoding: 'UTF-8').each_with_index do |parsed_row, idx|
        if parsed_row['number'].to_s.strip.empty?
          (errors['General'] ||= []) << "An entry around line #{idx} has no number"
          next
        end
        row_hash = parsed_row.to_hash
        # Hardcode the number, just to make sure we don't run into issues
        dev_number = row_hash['number'] = row_hash['number'].gsub(/\D+/,'')

        if data[dev_number]
          (errors[dev_number] ||= []) << "Is a duplicate entry"
          next
        end
        # remove ' =" " ' from values
        row_hash.each{ |k,v| row_hash[k] = v =~ /^="(.*?)"/ ? $1 : v }

        # converts string t or f into boolean
                                           # This is postgres-specific
        row_hash.each{ |k,v| row_hash[k] = ['t','f'].include?(v) ? (v == 't') : v }

        # move accounting_category to accounting_categories and deletes col
        # replace value(name) w/  id(from lookups)
        accounting_categories = []
        row_hash.dup.select{|k,_| lookups.key?(k)}.each do |k,v|
          if k =~ /accounting_categories\[(.*?)\]/
            accounting_category_name = $1
            accounting_category_code_id = lookups[k][v.to_s.strip]

            if accounting_category_code_id
              accounting_categories << accounting_category_code_id
            else
              (errors[dev_number] ||= []) << "New \"#{accounting_category_name}\" code: \"#{v}\""
            end
            row_hash.delete(k)
          else
            row_hash[k] = lookups[k][v]
          end
        end

        # sets ids for accounting_category relation
        row_hash['accounting_category_ids'] = accounting_categories if accounting_categories.any?

                                    #(looks like key maybe empty?(column w/o header?))
        data[dev_number] = row_hash.select{ |k,_| k }
      end
    rescue => e
      errors['General'] = [e.message]
    end
    [data, errors]
  end


  def self.import(contents, customer, current_user, clear_existing_data)
    errors        = {}
    flash         = {}

    lookups = customer.lookup_accounting_category

    errors = invalid_accounting_types_in_csv(contents, lookups)
    return [flash, errors] if errors.any?

    lookups.merge!(lookup_relation_ids_by_customer(customer))

    data, errors = parse_csv(contents, lookups)

    # validate the devices w/ same numbers do not belong other customer
    duplicate_numbers = unscoped.where(number: data.select{|_,v|v['status'] != 'cancelled'}.keys).where.not(status: 'cancelled').where.not(customer_id: customer.id)
    duplicate_numbers.each do |device|
        (errors[device.number] ||= []) << "Duplicate number. The number can only be processed once, please ensure it's on the active account number."
    end

    return [flash, errors] if errors.any?

    updated_devices = {}
    deleted_devices_ids  = []

    #find updated and deleted devices
    devices = customer.devices.reload.to_a
    devices.each do |device|
      if data.has_key?(device.number)
        updated_devices[device.number] = device
      elsif clear_existing_data
        deleted_devices_ids << device.id
      end
    end

    transaction do
      updated_devices.each do |dev_number, device|
        device.assign_attributes(data[dev_number].merge(customer_id: customer.id))
      end

      data.each do |dev_number, attributes|
        unless updated_devices[dev_number]
          updated_devices[dev_number] = new
          updated_devices[dev_number].assign_attributes(attributes.merge(customer_id: customer.id))
        end
      end

      updated_devices.each do |dev_number, device|
        unless device.valid?
          errors[dev_number] = device.errors.full_messages
        end
      end

      raise ActiveRecord::Rollback if errors.any?

      updated_devices.each do |_, device|
        device.track!(created_by: current_user, source: "Bulk Import") { device.save(validate: false) }
      end

      Device.where(id: deleted_devices_ids).delete_all if clear_existing_data

      flash[:notice] = "Import successfully completed. #{updated_devices.length} lines updated/added. #{deleted_devices_ids.length} lines removed."
    end
    [flash, errors]
  end


  def cancelled?
    status == 'cancelled'
  end


  def track!(params, &block)
    yield
  end
end