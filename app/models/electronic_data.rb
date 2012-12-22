class ElectronicData < ActiveRecord::Base
  belongs_to :datasheet
  belongs_to :item_type
end
