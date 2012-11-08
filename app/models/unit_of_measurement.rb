class UnitOfMeasurement < ActiveRecord::Base
  belongs_to :project
  belongs_to :measurement
  belongs_to :measurement_sub_type
  belongs_to :measure_unit
  
  
  #UNIT OF MEASUREMENT
  def self.unit_conversion(value)
    
  end

end
