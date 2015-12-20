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
    }                                      #faster then reqexp
    (column_names - blacklist).reject{ |c| c.ends_with?('_at') } # Reject timestamps
  end


  def self.import(contents, customer, current_user, clear_existing_data)
    data          = {}
    updated_lines = {}
    lookups       = {}
    delete_lines  = []
    errors = {}
    flash = {}

    #
    # ALO
    # PREPARE lookups - gets id and names for device relations and customer accounting_types
    #
    import_export_columns.each do |col|
      if col =~ /^(\w+)_id/
        case col
        when 'device_make_id'  then lookups[col] = Hash[DeviceMake.pluck(:name, :id)]
        when 'device_model_id' then lookups[col] = Hash[DeviceModel.pluck(:name, :id)]
        else
          reflections.each do |k, reflection|
            if reflection.foreign_key == col
              puts reflection.inspect
              method = reflection.plural_name.to_sym
              if customer.respond_to?(method)
                accessor = reflection.klass.respond_to?(:export_key) ? reflection.klass.send(:export_key) : 'name'
                lookups[col] = Hash[customer.send(method).pluck(accessor, :id)]
              end
            end
          end
        end
      end
    end

      #
      # ALO
      # add for customer customer_accounting_categories can be helpful here
    customer.accounting_types.each do |at|
      lookups["accounting_categories[#{at.name}]"] = Hash[Hash[at.accounting_categories.pluck(:name, :id)].map{ |k,v| [k.strip, v] }]
    end

    #
    # ALO
    # validation accounting_categories type (inside col names)
    #
    begin
      #
      # ALO
      # don't needed to go through rows - in case all ok it will be spend time
      #
      CSV.parse(contents, headers: true, encoding: 'UTF-8').each do |row|
        row.headers.each do |header|
          if header =~ /accounting_categories\[([^\]]+)\]/
            unless lookups.key?(header)
              raise "'#{$1}' is not a valid accounting type"
            end
          end
        end
        break
      end
    rescue => e
      errors['General'] = [e.message]
    end



    #
    # ALO
    # errors.any? - looks better - but check for speed.
    #
    if errors.length.nonzero?
      return [flash, errors]
    end

    begin
      CSV.parse(contents, headers: true, encoding: 'UTF-8').each_with_index do |p, idx|
        accounting_categories = []
        hsh = p.to_hash.merge(customer_id: customer.id)

        if '' == p['number'].to_s.strip
          (errors['General'] ||= []) << "An entry around line #{idx} has no number"
          next
        end

        #
        # ALO
        # just remove non digital values from number
        #

        # Hardcode the number, just to make sure we don't run into issues
        hsh['number'] = p['number'] = hsh['number'].gsub(/\D+/,'')


        #
        # ALO
        # check for duplicate line(by number) in the uploaded file
        #

        if data[p['number']]
          (errors[p['number']] ||= []) << "Is a duplicate entry"
          next
        end

        #
        # ALO
        # remove ' =" " ' from values
        #
        hsh = Hash[hsh.map{ |k,v| [k, v =~ /^="(.*?)"/ ? $1 : v] }]


        #
        # ALO
        # check for existent accounting_category code
        # move accounting_category to accounting_categories and deletes col with []
        # replace value w/ value from lookup - id instead of name
        #


        hsh.dup.each do |k,v|
          if lookups.key?(k)
            #
            # ALO
            # let's use k =~ /accounting_categories\[(.*?)\]/  and $1 inside
            #
            if k =~ /accounting_categories/
              accounting_category_name = k.gsub(/accounting_categories\[(.*?)\]/, '\1')
              val = lookups[k][v.to_s.strip]

              if !val
                (errors[p['number']] ||= []) << "New \"#{accounting_category_name}\" code: \"#{v.to_s.strip}\""
              else
                accounting_categories << lookups[k][v.to_s.strip]
              end
              hsh.delete(k)
            else
              hsh[k] = lookups[k][v]
            end
          end
          #
          # ALO
          # converts string t or f into boolean
          #
          if v == 't' || v == 'f'
            # This is postgres-specific
            hsh[k] = (v == 't')
          end
        end

        #
        # ALO
        # sets ids for  accounting_category relation
        # and prepare record
        #
        hsh['accounting_category_ids'] = accounting_categories unless accounting_categories.empty?
        #
        # ALO
        # put into data w/ number key all not emty keys and data (why key maybe empty?(column w/o header?))
        #
        data[p['number']] = hsh.select{ |k,v| k }
      end
    rescue => e
      errors['General'] = [e.message]
    end

    #
    # ALO
    # validate the devices w/ same numbers do not belong other customer
    # (number should be uniq for not cancelled device - maybe validation here)
    #
    duplicate_numbers = where(number: data.keys).where.not(customer_id: customer.id)
    duplicate_numbers.each do |device|
      if !device.cancelled? && data[device.number]['status'] != 'cancelled'
        (errors[device.number] ||= []) << "Duplicate number. The number can only be processed once, please ensure it's on the active account number."
      end
    end


    # Shortcut here to get basic errors out of the way
    return [flash, errors] if errors.any?

    #
    # ALO
    # check for such device is present - if flag  clear_existing_data setted up - then add all other device lines to deleted list
    #                        for  spec
    lines = customer.devices.reload.to_a
    lines.each do |line|
      if data.has_key?(line.number)
        updated_lines[line.number] = line
      elsif clear_existing_data
        delete_lines << line
      end
    end

    transaction do

      #
      # ALO
      # Maybe find_or_create should be better then this stuf...
      #
      updated_lines.each do |number, line|
        line.assign_attributes(data[number])
      end


      data.each do |number, attributes|
        unless updated_lines[number]
          updated_lines[number] = new
          updated_lines[number].assign_attributes(attributes)
        end
      end

      #
      # ALO
      # validation of each line
      #
      updated_lines.each do |number, line|
        unless line.valid?
          errors[number] = line.errors.full_messages
        end
      end

      #
      # ALO
      # check for number existent for other user and does not canceled
      # DOUBLE CHECK ???
      # OR DEFAULT SCOPE SOMEHOW PREVENTS THIS CHECK ABOVE???
      #
      number_conditions = []
      updated_lines.each do |number, device|
        number_conditions << "(number = '#{number}' AND status <> 'cancelled')" unless device.cancelled?
      end

      if number_conditions.size.nonzero?
        invalid_devices = unscoped.where("(#{number_conditions.join(' OR ')}) AND customer_id != ?", customer.id)
        invalid_devices.each do |device|
          (errors[device.number] ||= []) << "Already in the system as an active number"
        end
      end



      if errors.empty?
        updated_lines.each do |number, line|
          line.track!(created_by: current_user, source: "Bulk Import") { line.save(validate: false) }
        end

        #
        # ALO
        # convert to one request delete_all
        #
        delete_lines.each{ |line| line.delete } if clear_existing_data



        flash[:notice] = "Import successfully completed. #{updated_lines.length} lines updated/added. #{delete_lines.length} lines removed."
      else
        raise ActiveRecord::Rollback
      end
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