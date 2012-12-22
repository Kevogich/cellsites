class VendorDataRequirement < ActiveRecord::Base
  validates :vendor_data_requirement, :presence => true
end
