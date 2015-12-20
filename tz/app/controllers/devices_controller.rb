require 'csv'

class DevicesController < ApplicationController
#class DevicesController < InheritedResources::Base

  #added just for test
  attr_accessor :current_user

  def import
    @warnings = []
    clear_existing_data = params[:clear_existing_data]

    # We need this in a string since we parse it twice and Ruby will
    # automatically close and GC it if we don't
    import_file = params[:import_file]
    unless  import_file
      flash[:error] = 'Please upload a file to be imported' 
      return
    end

    unless @customer.devices.any?
      @warnings << 'This customer has no devices. The import file needs to have at least the following columns: number, username, business_account_id, device_make_id'
    end

    unless @customer.business_accounts.any?
      @warnings << 'This customer does not have any business accounts.  Any device import will fail to process correctly.'
    end
    #
    # ALO
    # ask or note - if file can be huge it's not good idea to read whole file
    #
    contents = import_file.tempfile.read.encode(invalid: :replace, replace: '')

    if request.post?
      flash_rez, @errors = Device.import(contents, @customer, current_user, clear_existing_data)
    end
    flash.update flash_rez
  end
end
