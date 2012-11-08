class MeasurementSubType < ActiveRecord::Base
  belongs_to :measurement
  
  has_many :measure_units, :dependent => :destroy
  has_many :unit_of_measurements, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :measurement_id}
end
