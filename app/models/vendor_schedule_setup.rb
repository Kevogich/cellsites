class VendorScheduleSetup < ActiveRecord::Base
  belongs_to :item_type
  has_one :vendor_data_requirement
  end
