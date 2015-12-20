require "rails_helper"

RSpec.describe DevicesController, :type => :controller do
  describe "POST #import" do
    def get_uploaded_file(file_name)
      fixture_file_upload("files/#{file_name}.csv", 'text/csv')
    end

    let!(:customer) { Customer.create() }
    let(:devices_json) do
      Device.all.map(&:serializable_hash)
        .map{|l|l.reject{|k,_| ["updated_at", "created_at"].include?(k)}}.to_json
    end
    let!(:business_account) { BusinessAccount.create(customer_id: customer.id, name: '01074132') }
    let!(:accounting_type1) { AccountingType.create(customer_id: customer.id, name: 'Reports To') }
    let!(:accounting_type2) { AccountingType.create(customer_id: customer.id, name: 'Cost Center') }
    let!(:acc_cat1) { AccountingCategory.create(accounting_type_id: accounting_type2.id, name: '10010.8350') }
    let!(:acc_cat2) { AccountingCategory.create(accounting_type_id: accounting_type2.id, name: '10083.8350') }
    let!(:acc_cat3) { AccountingCategory.create(accounting_type_id: accounting_type2.id, name: '26837.7037.18') }
    let!(:acc_cat4) { AccountingCategory.create(accounting_type_id: accounting_type1.id, name: '10010 Corporate Development') }
    let!(:acc_cat5) { AccountingCategory.create(accounting_type_id: accounting_type1.id, name: '10083 INT - International') }
    let!(:acc_cat6) { AccountingCategory.create(accounting_type_id: accounting_type1.id, name: '26837 Carson Wainwright') }
    before do
     controller.instance_variable_set(:@customer, customer)
     allow(controller).to receive(:current_user).and_return('current_user')
    end

    it 'set error message if file not present' do
      post :import
      expect(response).to have_http_status(:ok)
      expect(flash[:error]).to eq 'Please upload a file to be imported'
    end

    it 'import data into Device' do
      post :import, import_file: get_uploaded_file('data')
      expect(response).to have_http_status(:ok)
      expect(flash[:notice]).to eq 'Import successfully completed. 4 lines updated/added. 0 lines removed.'
      expect(devices_json).to eq "[{\"id\":1,\"number\":\"5879814504\",\"customer_id\":1,\"business_account_id\":1074132,\"device_model_id\":0,\"device_make_id\":0,\"carrier_base_id\":\"Telus\",\"device_model_mapping_id\":null,\"carrier_rate_plan_id\":null,\"contact_id\":null,\"model_id\":null,\"model\":\"iPad Air 32GB\",\"heartbeat\":null,\"hmac_key\":null,\"hash_key\":null,\"additional_data\":null,\"deferred\":null,\"deployed_until\":null,\"transfer_token\":null,\"username\":\"Guy Number 1\",\"location\":\"Edmonton\",\"contract_expiry_date\":null,\"email\":null,\"inactive\":\"f\",\"in_suspension\":\"f\",\"is_roaming\":\"f\",\"imei_number\":\"\",\"sim_number\":\"8912230000293881017\",\"employee_number\":null,\"additional_data_old\":\"{\\\"accounting_categories_percentage\\\":[\\\"100\\\"],\\\"partial_accounting_categories\\\":null}\",\"added_features\":\"International Calling On, International Voice Roaming On, Corp Roam Intl Zone1\",\"current_rate_plan\":\"Cost Assure Data for Tablet\",\"data_usage_status\":\"unblocked\",\"transfer_to_personal_status\":\"not_transfered\",\"apple_warranty\":\"{}\",\"eligibility_date\":null,\"number_for_forwarding\":null,\"call_forwarding_status\":\"not_active\",\"asset_tag\":null,\"status\":\"active\"},{\"id\":2,\"number\":\"4038283663\",\"customer_id\":1,\"business_account_id\":1074132,\"device_model_id\":1,\"device_make_id\":1,\"carrier_base_id\":\"Telus\",\"device_model_mapping_id\":null,\"carrier_rate_plan_id\":null,\"contact_id\":null,\"model_id\":null,\"model\":\"6\",\"heartbeat\":null,\"hmac_key\":null,\"hash_key\":null,\"additional_data\":null,\"deferred\":null,\"deployed_until\":null,\"transfer_token\":null,\"username\":\"Guy Number 2\",\"location\":\"Calgary\",\"contract_expiry_date\":\"2018-10-07\",\"email\":null,\"inactive\":\"f\",\"in_suspension\":\"f\",\"is_roaming\":\"f\",\"imei_number\":\"359307063973495\",\"sim_number\":\"8912230000193245107\",\"employee_number\":\"231134\",\"additional_data_old\":\"{\\\"accounting_categories_percentage\\\":[\\\"100\\\"],\\\"partial_accounting_categories\\\":null}\",\"added_features\":\"Minutes 150, Corp Roam US Rates, International Data Roaming On\",\"current_rate_plan\":\"Corp $12.50 PCS Voice Plan\",\"data_usage_status\":\"unblocked\",\"transfer_to_personal_status\":\"not_transfered\",\"apple_warranty\":\"{}\",\"eligibility_date\":null,\"number_for_forwarding\":null,\"call_forwarding_status\":\"not_active\",\"asset_tag\":null,\"status\":\"active\"},{\"id\":3,\"number\":\"4038269268\",\"customer_id\":1,\"business_account_id\":1074132,\"device_model_id\":2,\"device_make_id\":1,\"carrier_base_id\":\"Telus\",\"device_model_mapping_id\":null,\"carrier_rate_plan_id\":null,\"contact_id\":null,\"model_id\":null,\"model\":\"5C\",\"heartbeat\":null,\"hmac_key\":null,\"hash_key\":null,\"additional_data\":null,\"deferred\":null,\"deployed_until\":null,\"transfer_token\":null,\"username\":\"Vacation Disconnect\",\"location\":\"Calgary\",\"contract_expiry_date\":\"2016-04-11\",\"email\":null,\"inactive\":\"f\",\"in_suspension\":\"t\",\"is_roaming\":\"f\",\"imei_number\":\"013838005788920\",\"sim_number\":\"8912230000147718936\",\"employee_number\":null,\"additional_data_old\":\"{\\\"accounting_categories_percentage\\\":[\\\"100\\\"],\\\"partial_accounting_categories\\\":null}\",\"added_features\":\"International Data Roaming\",\"current_rate_plan\":\"Corp $12.50 PCS Voice Plan\",\"data_usage_status\":\"unblocked\",\"transfer_to_personal_status\":\"not_transfered\",\"apple_warranty\":\"{}\",\"eligibility_date\":null,\"number_for_forwarding\":null,\"call_forwarding_status\":\"not_active\",\"asset_tag\":null,\"status\":\"suspended\"},{\"id\":4,\"number\":\"7808161381\",\"customer_id\":1,\"business_account_id\":1074132,\"device_model_id\":3,\"device_make_id\":2,\"carrier_base_id\":\"Telus\",\"device_model_mapping_id\":null,\"carrier_rate_plan_id\":null,\"contact_id\":null,\"model_id\":null,\"model\":\"LG A341\",\"heartbeat\":null,\"hmac_key\":null,\"hash_key\":null,\"additional_data\":null,\"deferred\":null,\"deployed_until\":null,\"transfer_token\":null,\"username\":\"Vacation Disconnect\",\"location\":\"Wainwright\",\"contract_expiry_date\":\"2016-04-11\",\"email\":null,\"inactive\":\"f\",\"in_suspension\":\"f\",\"is_roaming\":\"f\",\"imei_number\":\"352262051494995\",\"sim_number\":\"8912230000126768100\",\"employee_number\":null,\"additional_data_old\":\"{\\\"accounting_categories_percentage\\\":[\\\"100\\\"],\\\"partial_accounting_categories\\\":null}\",\"added_features\":\"Corp Roam Intl Zone2, Corp Roam US Rates,Corp - Unlimited text msg\",\"current_rate_plan\":\"Corp $12.50 PCS Voice Plan\",\"data_usage_status\":\"unblocked\",\"transfer_to_personal_status\":\"not_transfered\",\"apple_warranty\":\"{}\",\"eligibility_date\":null,\"number_for_forwarding\":null,\"call_forwarding_status\":\"not_active\",\"asset_tag\":null,\"status\":\"active\"}]"
    end

    it 'track any imported record' do
      expect_any_instance_of(Device).to receive(:track!)
      post :import, import_file: get_uploaded_file('data1')
    end


    it 'add warning message in case user has not got devices' do
      post :import, import_file: get_uploaded_file('data')
      expect(controller.instance_variable_get(:@warnings)).to eq ["This customer has no devices. The import file needs to have at least the following columns: number, username, business_account_id, device_make_id"]
    end

    it 'add warning message in case user has not got business account' do
      customer.business_accounts.delete_all
      post :import, import_file: get_uploaded_file('data')
      expect(controller.instance_variable_get(:@warnings)).to include('This customer does not have any business accounts.  Any device import will fail to process correctly.')
    end

    it 'add error message and do not import data in case at least one line of file has empty number ' do
      post :import, import_file: get_uploaded_file('data_empty_number')
      expect(controller.instance_variable_get(:@errors)["General"]).to eq ['An entry around line 3 has no number']
      expect(Device.count).to eq 0
    end

    it 'add error message and do not import data in case at least one line  has duplicated number ' do
      post :import, import_file: get_uploaded_file('data_dublicated_number')
      expect(controller.instance_variable_get(:@errors).values).to include(['Is a duplicate entry'])
      expect(Device.count).to eq 0
    end


    it 'add error message and do not import data in case at least one device number already present for other customer' do
      Device.create(customer_id: 2, number: '5879814504')
      post :import, import_file: get_uploaded_file('data1')
      expect(controller.instance_variable_get(:@errors).values).to include(["Duplicate number. The number can only be processed once, please ensure it's on the active account number."])
      expect(Device.count).to eq 1
    end

    it 'does not add error message and import data in case duplicated number, but device has status canceled' do
      Device.create(customer_id: 2, number: '5879814504', status: 'cancelled')
      post :import, import_file: get_uploaded_file('data1')
      expect(controller.instance_variable_get(:@errors).values).to_not include(["Duplicate number. The number can only be processed once, please ensure it's on the active account number."])
      expect(Device.count).to eq 2
    end

    it 'does not add error message and import data in case duplicated number with canceled status' do
      Device.create(customer_id: 2, number: '5879814504')
      post :import, import_file: get_uploaded_file('data_duplicated_number_canceled')
      expect(controller.instance_variable_get(:@errors).values).to_not include(["Duplicate number. The number can only be processed once, please ensure it's on the active account number."])
      expect(Device.count).to eq 2
    end

    it 'add error message and do not import data in case at least one accounting type is not known' do
      post :import, import_file: get_uploaded_file('data_invalid accounting type')
      expect(controller.instance_variable_get(:@errors).values).to include(["'INVALID' is not a valid accounting type"])
      expect(Device.count).to eq 0
    end

    it 'add error message and do not import data in case found unknown accounting category value' do
      post :import, import_file: get_uploaded_file('data_invalid_accounting_category_value')
      expect(controller.instance_variable_get(:@errors).values).to include(["New \"Reports To\" code: \"NEW ACCOUNTING CATEGORY VALUE\""])
      expect(Device.count).to eq 0
    end

    it 'remove non digits from number' do
      post :import, import_file: get_uploaded_file('data_non_digits_in_number')
      expect(Device.first.number).to eq "5879814504"
    end

    it 'remove =" " from values ' do
      post :import, import_file: get_uploaded_file('data1')
      expect(Device.first.sim_number).to eq "8912230000293881017"
    end

    it 'delete existent data in case param clear_existing_data' do
      post :import, import_file: get_uploaded_file('data')
      expect(Device.count).to eq 4
      post :import, import_file: get_uploaded_file('data1'), clear_existing_data: true
      expect(flash[:notice]).to eq 'Import successfully completed. 1 lines updated/added. 3 lines removed.'
      expect(devices_json).to eq "[{\"id\":1,\"number\":\"5879814504\",\"customer_id\":1,\"business_account_id\":1074132,\"device_model_id\":0,\"device_make_id\":0,\"carrier_base_id\":\"Telus\",\"device_model_mapping_id\":null,\"carrier_rate_plan_id\":null,\"contact_id\":null,\"model_id\":null,\"model\":\"iPad Air 32GB\",\"heartbeat\":null,\"hmac_key\":null,\"hash_key\":null,\"additional_data\":null,\"deferred\":null,\"deployed_until\":null,\"transfer_token\":null,\"username\":\"Guy Number 1 Updated\",\"location\":\"Edmonton\",\"contract_expiry_date\":null,\"email\":null,\"inactive\":\"f\",\"in_suspension\":\"f\",\"is_roaming\":\"f\",\"imei_number\":\"\",\"sim_number\":\"8912230000293881017\",\"employee_number\":null,\"additional_data_old\":\"{\\\"accounting_categories_percentage\\\":[\\\"90\\\"],\\\"partial_accounting_categories\\\":null}\",\"added_features\":\"International Calling On, International Voice Roaming On, Corp Roam Intl Zone1\",\"current_rate_plan\":\"Cost Assure Data for Tablet\",\"data_usage_status\":\"unblocked\",\"transfer_to_personal_status\":\"not_transfered\",\"apple_warranty\":\"{}\",\"eligibility_date\":null,\"number_for_forwarding\":null,\"call_forwarding_status\":\"not_active\",\"asset_tag\":null,\"status\":\"active\"}]"
    end
  end
end