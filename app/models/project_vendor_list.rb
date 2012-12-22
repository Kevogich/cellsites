class ProjectVendorList < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor_list

end
