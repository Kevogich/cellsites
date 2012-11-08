class PumpSizingDischarge < ActiveRecord::Base
  belongs_to :pump_sizing

  has_many :discharge_circuit_piping, :as => :discharge_circuit_pipings, :dependent => :destroy
  
  after_save :save_discharge_circuit_pipings
  
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

  #calculate fitting DP, Equipment DP, Control Valve DP, Orifice DP
  def calculate_and_save_delta_ps

   fittings = PipeSizing.fitting1
    orifice_id = nil
    fittings.each {|item| orifice_id = item[:id] if item[:value] == 'Orifice' }
	  orifice_dp = self.discharge_circuit_piping.sum(:delta_p, :conditions => ['fitting = ? ', orifice_id])

    #calculate flow elements sum
    flow_element_ids = []

    fittings.each do |item| 
      if item[:value].include?("Flow")
        flow_element_ids << item[:id] 
      end
    end

    flow_elements_dp_sum = 0.0
    self.discharge_circuit_piping.where({:fitting => flow_element_ids}).each do |f|
      flow_elements_dp_sum = flow_elements_dp_sum + f.delta_p
    end

    #add flow elements dp sum to orifice dp
    orifice_dp = orifice_dp + flow_elements_dp_sum

    equipment_id = nil
    fittings.each {|item| equipment_id = item[:id] if item[:value] == 'Equipment' }
	  equipment_dp = self.discharge_circuit_piping.sum(:delta_p, :conditions => ['fitting = ? ', equipment_id])

    control_valve_id = nil
    fittings.each {|item| control_valve_id  = item[:id] if item[:value] == 'Control Valve' }
	  control_valve_dp = self.discharge_circuit_piping.sum(:delta_p, :conditions => ['fitting = ? ', control_valve_id])

	total_system_dp =  discharge_circuit_piping.sum(:delta_p)
  fitting_dp = total_system_dp - (equipment_dp + control_valve_dp + orifice_dp)

	unit_decimals = self.pump_sizing.project.project_units

	pressure_at_discharge_nozzle = destination_pressure + total_system_dp

  	update_attributes(
    :fitting_dp => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
		:equipment_dp => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
		:control_valve_dp => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
		:orifice_dp => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
		:total_system_dp => total_system_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i),
		:pressure_at_discharge_nozzle_dp => pressure_at_discharge_nozzle.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i)
	)
  end

end
