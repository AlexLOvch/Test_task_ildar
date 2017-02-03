Task description can be found here: ./task_description.txt
__________________


Plan of the attack:
1. Scaffold rails app
2. Create all needed models
3. Create specs for import
4. Refactor import

Notes:
  1. Customer data(like fio etc) are ignored(only id is enough)
  2. DeviceMake and DeviceModel stubbed(so name will be replace with id as needed)
  3. Looks like should be: "serialize :additional_data (and/or :additional_data_old), JSON" - ignored - b/c of in black list - does not export and import
  4. Most likely: device has_one contact, device has_one model and device has_one carrier_base_id - ignored - same thing as  business_account_id - value should be replace w/ id in case these models will have relations with device(through reflections)
  5. Don't clear w/ device_model_mapping_id - maybe another relation - ignored - also used as string
  6. track! for ActiveRecord::Base stubbed - looks like used for logging device import
  7. @customer stubbed(probably setted by InheritedResources::Base - inheritedresources ignore b/c of irrelevant to refactoring task)
  8. Some device fields should be boolean(like inactive, in_sespension, etc). Left string - no difference for this refactoring.
  9. As far as any device updated or created checks for valid? - length validation added for device.number(just for test validation checks)


