class VendorList < ActiveRecord::Base
  STATUS = ["Active", "Inactive","Preferred"]
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :project_vendor_lists
  has_many :projects, :through => :project_vendor_lists
  belongs_to :company
  acts_as_commentable
end
