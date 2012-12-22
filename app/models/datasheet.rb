class Datasheet < ActiveRecord::Base
  belongs_to :ite_type
  validates :datasheet_name, :presence => true
  has_one :electronic_data
end
