class MeasureUnit < ActiveRecord::Base
   belongs_to :company   
   belongs_to :measurement
   belongs_to :measurement_sub_type
   has_many :unit_of_measurements, :dependent => :destroy
   
   validates_presence_of :measurement_id, :measurement_sub_type_id, :unit_name, :unit, :base_unit
   #validates_numericality_of :decimal_places, :only_integer => true
   
   def unit_type
     { 1 => "US Customary", 2 => "SI" }[ unit_type_id ]
   end
   
   def self.get_unit(measurement, measurement_sub_type, unit_type)
     unit = where("measurements.name = ? AND measurement_sub_types.name = ? AND measure_units.unit_type_id = ?", measurement, measurement_sub_type, unit_type).joins(:measurement, :measurement_sub_type).first
     unit.unit rescue nil
   end
   
   def self.unit(measurement, measurement_sub_type)
     unit = self.get_unit(measurement, measurement_sub_type)
     unit.unit rescue nil
   end 

end
