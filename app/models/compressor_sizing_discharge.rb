class CompressorSizingDischarge < ActiveRecord::Base
  belongs_to :compressor_sizing
  has_many :discharge_circuit_piping, :as => :discharge_circuit_pipings, :dependent => :destroy
  
  after_save :save_discharge_circuit_pipings
  accepts_nested_attributes_for :discharge_circuit_piping, :allow_destroy => true
  
  def discharge_circuit_pipings=(dcp_params)
    @dcp_params = dcp_params
  end
  
  def save_discharge_circuit_pipings
    #raise @dcp_params.to_yaml   
    @dcp_params.each do |i, dcp_param|
      dcp = discharge_circuit_piping.where(:id => dcp_param[:id]).first       
      discharge_circuit_piping.create(dcp_param) if dcp.nil? && !dcp_param[:fitting].blank?      
      dcp.delete if !dcp.nil? && dcp_param[:fitting].blank? #delete
      dcp.update_attributes(dcp_param) if !dcp.nil? && !dcp_param[:fitting].blank? #update
    end if !@dcp_params.nil?
  end 

def calculate_suction_dps
	  unit_decimals = self.compressor_sizing.compressor_sizing_tag.project.project_units
	  #assuming 51 for fitting type orifice
	  orifice_dp = self.discharge_circuit_piping.sum(:delta_p, :conditions => ['fitting = ? ', 51])
	  #assuming 49 for fitting type equipment
	  equipment_dp = self.discharge_circuit_piping.sum(:delta_p, :conditions => ['fitting = ? ', 49])
	  #assuming 52 for fitting type control valve
	  control_valve_dp = self.discharge_circuit_piping.sum(:delta_p, :conditions => ['fitting = ? ', 52])

	  fitting_dp = self.discharge_circuit_piping.sum(:delta_p)

	  total_system_dp = orifice_dp+equipment_dp+control_valve_dp+fitting_dp
	  pressure_at_discharge_nozzle = self.destination_pressure - total_system_dp

	  self.update_attributes(:fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :total_system_dp => total_system_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
							 :pressure_at_discharge_nozzle_dp => pressure_at_discharge_nozzle.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i)
							)
  end
end
