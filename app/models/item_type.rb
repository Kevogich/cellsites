class ItemType < ActiveRecord::Base
  validates :item_type, :presence => true
  has_many :vendor_schedule_setups
 # belongs_to :project
  has_many :project_item_types
  has_many :projects, :through => :project_item_types
  belongs_to :company
  has_many :item_types_transmit_and_proposals
  has_many :procure_items
  has_many :request_for_quotation_setups, :dependent => :delete_all
  has_many :datasheets

end
