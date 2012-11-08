class PumpSizing < ActiveRecord::Base
 belongs_to :company
 belongs_to :client
 belongs_to :project
 belongs_to :process_unit
 has_many :suction_pipings, :as => :suction_pipe, :dependent => :destroy
 has_many :pump_sizing_discharges, :dependent => :destroy
 has_many :centrifugal_pumps, :dependent => :destroy
 has_many :attachments, :as => :attachable, :dependent => :destroy
 has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

 acts_as_commentable

 validates_presence_of :centrifugal_pump_tag, :project_id, :process_unit_id

 after_save :save_suction_pipings, :save_pump_sizing_discharges, :save_centrifugal_pumps

 after_create :add_default_fields

 #to store all the calculated fe summary and cv summary in one blob of array
  serialize :fe_summary, Array
  serialize :cv_summary, Array


def add_default_fields
  update_attributes(
    :cd_shut_off_factor => project.centrifugal_pump_shut_off_factor,
    :cd_efficiency => project.default_centrifugal_pump_efficiency,
    :rd_mechanical_efficiency => project.positive_displacement_mechanical_efficiency
    )
end

def centrifugal_pumps=(cp_params)
 @cp_params = cp_params
end

def suction_pipings=(sp_params)
 @sp_params = sp_params
end

def save_suction_pipings
    #raise @sp_params.to_yaml
    @sp_params.each do |i, sp_param|      
      sp = suction_pipings.where(:id => sp_param[:id]).first     
      suction_pipings.create(sp_param) if sp.nil? && !sp_param[:fitting].blank? #create
      sp.delete if !sp.nil? && sp_param[:fitting].blank? #delete
      sp.update_attributes(sp_param) if !sp.nil? && !sp_param[:fitting].blank? #update
    end if !@sp_params.nil?   
  end
  
  def pump_sizing_discharges=(psd_params)
   @psd_params = psd_params
 end

 def save_pump_sizing_discharges
     #raise @psd_params.to_yaml     
     @psd_params.each do |i, psd_param|       
       psd = pump_sizing_discharges.where(:id => psd_param[:id]).first
       pump_sizing_discharges.create(psd_param) if psd.nil? && !psd_param[:process_basis_id].blank? #create
       psd.delete if !psd.nil? && psd_param[:process_basis_id].blank? #delete
       psd.update_attributes(psd_param) if !psd.nil? && !psd_param[:process_basis_id].blank? #update
     end if !@psd_params.nil?
   end

   def save_centrifugal_pumps
    #raise @cp_params.to_yaml     
     @cp_params.each do |i, cp_param|       
       cp = centrifugal_pumps.where(:id => cp_param[:id]).first
       next if i == '#x#'

       #create
       if cp.nil? 
        cp_param.delete(:_destroy)
        centrifugal_pumps.create(cp_param) 
       end

      #delete
       if !cp.nil? && cp_param[:_destroy] == 'true'
        cp.delete 
       end

      #update
       if !cp.nil? && cp_param[:_destroy] == 'false'
        cp_param.delete(:_destroy)
        cp.update_attributes(cp_param) 
       end
    end if !@cp_params.nil?
end


   def self.pump_type_list
     ['Simplex Single Acting',
       'Simplex Double Acting',
       'Duplex Single Acting',
       'Duplex Double Acting',
       'Triplex Single Acting',
       'Triplex Double Acting',
       'Quintuplex Single Acting',
       'Quintuplex Double Acting',
       'Septuplex Single Acting',
       'Septuplex Double Acting',
       'Nonuplex Single Acting',
       'Nonuplex Double Acting']
     end

     def self.pump_type_form_values
      {
        "Simplex Single Acting"    => { :c => 0.4, :no_cylinders  => 1, :stroke_action => "Single-Acting"},
        "Simplex Double Acting"    => { :c => 0.2, :no_cylinders  => 1, :stroke_action => ""},
        "Duplex Single Acting"     => { :c => 0.2, :no_cylinders  => 2, :stroke_action => "Single-Acting"},
        "Duplex Double Acting"     => { :c => 0.115, :no_cylinders  => 2, :stroke_action => ""},
        "Triplex Single Acting"    => { :c => 0.066, :no_cylinders  => 3, :stroke_action => "Single-Acting"},
        "Triplex Double Acting"    => { :c => 0.066, :no_cylinders  => 3, :stroke_action => ""},
        "Quintuplex Single Acting" => { :c => 0.04, :no_cylinders  => 5, :stroke_action => "Single-Acting"},
        "Quintuplex Double Acting" => { :c => 0.04, :no_cylinders  => 5, :stroke_action => ""},
        "Septuplex Single Acting"  => { :c => 0.028, :no_cylinders  => 7, :stroke_action => "Single-Acting"},
        "Septuplex Double Acting"  => { :c => 0.028, :no_cylinders  => 7, :stroke_action => ""},
        "Nonuplex Single Acting"   => { :c => 0.022, :no_cylinders  => 9, :stroke_action => "Single-Acting"},
        "Nonuplex Double Acting"   => { :c => 0.022, :no_cylinders  => 9, :stroke_action => ""}
      }
    end

    def self.fluid_service_types
     ["Hot Oil",
       "Hydrocarbon",
       "Amine",
       "Glycol",
       "Water",
       "Deaerated Water",
       "Liquid with Entrained Gas"]
     end

     def self.fluid_service_type_form_values
      {
        "Hot Oil" => {:k => 2.5},
        "Hydrocarbon" => {:k => 2},
        "Amine" => {:k => 1.5},
        "Glycol" => {:k => 1.5},
        "Water" => {:k => 1.5},
        "Deaerated Water" => {:k => 1.4},
        "Liquid with Entrained Gas" => {:k => 1}
      }
    end


    def uom_mapping
      {
        :su_pressure                       => ["Pressure", "General"],
        :su_temperature                    => ["Temperature", "General"],
        :su_mass_vapor_fraction            => ["Mass Vapor Fraction", "Dimensionless"],
        :su_mass_flow_rate                 => ["Mass Flow Rate", "General"],
        :su_density                        => ["Density", "General"],
        :su_viscosity                      => ["Viscosity", "Dynamic"],
        :su_specific_heat_capacity         => ["Specific Heat Capacity", "General"],
        :su_vapor_pressure                 => ["Pressure", "General"],
        :su_critical_pressure              => ["Pressure", "General"],
        :su_fitting_dP                     => ["Pressure","Differential"],
        :su_equipment_dP                   => ["Pressure", "Differential"],
        :su_control_valve_dP               => ["Pressure", "Differential"],
        :su_orifice_dP                     => ["Pressure", "Differential"],
        :su_pipe_roughness                 => ["Length","Small Dimension Length"],
        :su_total_suction_dP               => ["Pressure", "General"],
        :su_pressure_at_suction_nozzle     => ["Pressure", "General"],
        :su_max_upstream_pressure          => ["Pressure", "General"],
        :su_max_pressure_at_suction_nozzle => ["Pressure", "General"],
        :pipe_id                           => ["Length", "Small Dimension Length"],
        :dorifice                          => ["Length", "Small Dimension Length"],
        :length                            => ["Length", "Large Dimension Length"],
        :elevation                         => ["Length", "Large Dimension Length"],
        :delta_p                           => ["Pressure", "Differential"],
        :destination_pressure              => ["Pressure", "General"],
        :fitting_dp                        => ["Pressure", "Differential"],
        :equipment_dp                      => ["Pressure", "Differential"],
        :control_valve_dp                  => ["Pressure", "Differential"],
        :orifice_dp                        => ["Pressure", "Differential"],
        :total_system_dp                   => ["Pressure", "General"],
        :pressure_at_discharge_nozzle_dp   => ["Pressure","General"],
        :inlet_pressure                    => ["Pressure", "General"],
        :outlet_pressure                   => ["Pressure", "General"],
        :cd_press_at_suction_nozzle        => ["Pressure", "General"],
        :cd_np_press_at_suction_nozzle     => ["Pressure", "General"],
        :cd_press_at_discharge_nozzle      => ["Pressure", "General"],
        :cd_differential_pressure          => ["Pressure", "Differential"],
        :cd_differential_head              => ["Length", "Large Dimension Length"],
        :cd_safety_factor                  => ["Length", "Large Dimension Length"],
        :cd_required_differential_head     => ["Length", "Large Dimension Length"],
        :cd_shut_off_head                  => ["Length", "Large Dimension Length"],
        :cd_max_suction_pressure           => ["Pressure", "General"],
        :cd_shut_off_pressure              => ["Pressure", "General"],
        :cd_vapor_pressure                 => ["Pressure", "General"],
        :cd_npsha                          => ["Length", "Large Dimension Length"],
        :cd_temp_at_discharge_nozzle       => ["Temperature", "General"],
        :cd_density_at_discharge_nozzle    => ["Density", "General"],
        :cd_required_compression_head      => ["Length", "Large Dimension Length"],
        :cd_flow_rate                      => ["Volumetric Flow Rate", "Liquid"],
        :cd_s_g                            => ["Specific Gravity", "Dimensionless"],
        :cd_hydraulic_hp                   => ["Power", "General"],
        :cd_brake_horsepower               => ["Power", "General"],
        :rd_bore                           => ["Length", "Small Dimension Length"],
        :rd_stroke                         => ["Length", "Small Dimension Length"],
        :rd_rod_diameter                   => ["Length", "Small Dimension Length"],
        :rd_piston_speed                   => ["Speed", "General"],
        :rd_temp_at_discharge_nozzle       => ["Temperature", "General"],
        :rd_density_at_discharge_nozzle    => ["Density", "General"],
        :rd_compression_head               => ["Length", "Large Dimension Length"],
        :rd_press_at_suction_nozzle        => ["Pressure", "General"],
        :rd_press_at_discharge_nozzle      => ["Pressure", "General"],
        :rd_vapor_pressure                 => ["Pressure", "General"],
        :rd_acceleration_head              => ["Length", "Large Dimension Length"],
        :rd_npsha                          => ["Length", "Large Dimension Length"],
        :rd_differential_pressure          => ["Pressure", "Differential"],
        :rd_differential_head              => ["Length", "Large Dimension Length"],
        :rd_piston_displacement            => ["Volumetric Flow Rate", "Liquid"],
        :rd_rated_discharge_capacity       => ["Volumetric Flow Rate", "Liquid"],
        :rd_hydraulic_hp                   => ["Power", "General"],
        :rd_brake_horsepower               => ["Power", "General"],
        :pc_impellder                      => ["Length", "Small Dimension Length"],
        "Capacity"                         => ["Volumetric Flow Rate", "Liquid"],
        "System Loss"                      => ["Length", "Large Dimension Length"],
        "Head 1"                           => ["Length", "Large Dimension Length"],
        "Head 2"                           => ["Length", "Large Dimension Length"],
        "Head 3"                           => ["Length", "Large Dimension Length"],
        "Head 4"                           => ["Length", "Large Dimension Length"],
        "Flowrate"                         => ["Volumetric Flow Rate", "Liquid"],
        "Inlet Pressure"                   => ["Pressure", "General"],
        "Outlet Pressure"                  => ["Pressure", "General"],
        "CV Delta P"                       => ["Press", "Differential"],
        "Density"                          => ["Density", "General"],
        "Inlet Pressure"                   => ["Pressure", "General"],
        "Outlet Pressure"                  => ["Pressure", "General"],
        "CV Delta P"                       => ["Press", "Differential"],
        "Density"                          => ["Density", "General"],
        "Diameter"                         => ["Length", "Small Dimension Length"],
        "Liquid Capacity"                  => ["Volumetric Flow Rate", "Liquid"],
        "Length of Suction Pipe"           => ["Length", "Large Dimension Length"],
        "Diameter of Suction Pipe"         => ["Length", "Small Dimension Length"],
        "Speed of Rotation Revolution"     => ["Speed", "General"],
        "Velocity"                         => ["Velocity", "General"],
        "Head"                             => ["Length", "Large Dimension Length"]
      }
    end

    def convert_to_base_unit(att,value=nil)
      value = self.send(att) if value.nil?
      units = uom_mapping[att]

      if units[0] == 'Temperature'
        uom = self.project.get_uom_details(:mtype => units[0], :msub_type => units[1])
        converted = value.to_f.send(uom[:current_unit][:unit_name].downcase.to_sym).to.fahrenheit

      else
        cf = self.project.base_unit_cf(:mtype => units[0], :msub_type => units[1])
        converted = (value * cf[:factor ]).round(cf[:decimals])
      end
      return converted
    end

    def convert_to_project_unit(att,value)
      units = uom_mapping[att]

      if units[0] == 'Temperature'
        uom = self.project.get_uom_details(:mtype => units[0], :msub_type => units[1])
        converted = value.to_f.fahrenheit.to.send(uom[:current_unit][:unit_name].downcase.to_sym)
        cf = self.project.base_unit_cf(:mtype => units[0], :msub_type => units[1])
        converted = converted.round(cf[:decimals])
      else
        cf = self.project.base_unit_cf(:mtype => units[0], :msub_type => units[1])
        converted = (value/cf[:factor]).round(cf[:decimals])
      end
      return converted
    end

   #convert values
   def convert_values(multiply_factor)
    su_pressure = (su_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    su_temperature = convert_temperature(:value => su_temperature, :subtype => "General")      
    su_mass_flow_rate = (su_mass_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    su_density = (su_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    su_viscosity = (su_viscosity.to_f * multiply_factor["Viscosity"]["Dynamic"].to_f) if !multiply_factor["Viscosity"].nil?
    su_specific_heat_capacity = (su_specific_heat_capacity.to_f * multiply_factor["Specific Heat Capacity"]["General"].to_f) if !multiply_factor["Specific Heat Capacity"].nil?
    su_vapor_pressure = (su_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    su_critical_pressure = (su_critical_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    su_mass_vapor_fraction = (su_mass_vapor_fraction.to_f * multiply_factor["Mass Vapor Fraction"]["Dimensionless"].to_f) if !multiply_factor["Mass Vapor Fraction"].nil?
    su_fitting_dP = (su_fitting_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    su_equipment_dP = (su_equipment_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    su_control_valve_dP = (su_control_valve_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    su_orifice_dP = (su_orifice_dP.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    su_total_suction_dP = (su_total_suction_dP.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    su_pressure_at_suction_nozzle = (su_pressure_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    su_max_upstream_pressure = (su_max_upstream_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    su_max_pressure_at_suction_nozzle = (su_max_pressure_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    
      #Suction Circuit Piping
      suction_pipings.where(:tab=>"suction").each do |suction_piping|
        suction_piping.pipe_id = (suction_piping.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
        suction_piping.length = (suction_piping.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        suction_piping.elev = (suction_piping.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
        suction_piping.delta_p = (suction_piping.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        
        suction_piping.save        
      end
      
      #Discharge
      discharges.each do |discharge|
        discharge.destination_pressure = (discharge.destination_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        discharge.fitting_dp = (discharge.fitting_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        discharge.equipment_dp = (discharge.equipment_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        discharge.control_valve_dp = (discharge.control_valve_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        discharge.orifice_dp = (discharge.orifice_dp.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
        discharge.total_system_dp = (discharge.total_system_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        discharge.pressure_at_discharge_nozzle_dp = (discharge.pressure_at_discharge_nozzle_dp.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
        
        discharge.save
        
        discharge.discharge_circuit_piping.each do |dcp|
          dcp.pipe_id = (dcp.pipe_id.to_f * multiply_factor["Length"]["Pipe Tube Diameter"].to_f) if !multiply_factor["Length"].nil?
          dcp.length = (dcp.length.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
          dcp.elev = (dcp.elev.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
          dcp.delta_p = (dcp.delta_p.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
          dcp.inlet_pressure = (dcp.inlet_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
          
          dcp.save
        end
      end
      
      #Centrifugal Design
      cd_press_at_suction_nozzle = (cd_press_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_press_at_discharge_nozzle = (cd_press_at_discharge_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_differential_pressure = (cd_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      cd_differential_head = (cd_differential_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      cd_safety_factor = (cd_safety_factor.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      cd_required_differential_head = (cd_required_differential_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      cd_shut_off_head = (cd_shut_off_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      cd_max_suction_pressure = (cd_max_suction_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_shut_off_pressure = (cd_shut_off_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_np_press_at_suction_nozzle = (cd_np_press_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_vapor_pressure = (cd_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_npsha = (cd_npsha.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      cd_compressible_liquid = (cd_compressible_liquid.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      cd_temp_at_discharge_nozzle = convert_temperature(:value => cd_temp_at_discharge_nozzle, :subtype => "General")
      cd_density_at_discharge_nozzle = (cd_density_at_discharge_nozzle.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
      cd_required_compression_head = (cd_required_compression_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      cd_flow_rate = (cd_flow_rate.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
      cd_hydraulic_hp = (cd_hydraulic_hp.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
      cd_brake_horsepower = (cd_brake_horsepower.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
      
      #Reciprocation Design      
      rd_bore = (rd_bore.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_stroke = (rd_stroke.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_rod_diameter = (rd_rod_diameter.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_piston_speed = (rd_piston_speed.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
      rd_temp_at_discharge_nozzle = convert_temperature(:value => rd_temp_at_discharge_nozzle, :subtype => "General")
      rd_density_at_discharge_nozzle = (rd_density_at_discharge_nozzle.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
      rd_compression_head = (rd_compression_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_press_at_suction_nozzle = (rd_press_at_suction_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      rd_press_at_discharge_nozzle = (rd_press_at_discharge_nozzle.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      rd_vapor_pressure = (rd_vapor_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
      rd_acceleration_head = (rd_acceleration_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_npsha = (rd_npsha.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_differential_pressure = (rd_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
      rd_differential_head = (rd_differential_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_piston_displacement = (rd_piston_displacement.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
      rd_rated_discharge_capacity = (rd_rated_discharge_capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
      rd_hydraulic_hp = (rd_hydraulic_hp.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
      rd_brake_horsepower = (rd_brake_horsepower.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
      
      rd_liquid_capacity = (rd_liquid_capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
      rd_length_of_suction_pipe = (rd_length_of_suction_pipe.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      rd_speed_of_rotation = (rd_speed_of_rotation.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
      rd_velocity = (rd_velocity.to_f * multiply_factor["Velocity"]["General"].to_f) if !multiply_factor["Velocity"].nil?
      rd_head = (rd_head.to_f * multiply_factor["Length"]["Large Dimension Length"].to_f) if !multiply_factor["Length"].nil?
      pc
      self.save      
    end


  #calculate fitting DP, Equipment DP, Control Valve DP, Orifice DP
  def calculate_and_save_delta_ps

    fittings = PipeSizing.fitting1

    orifice_id = nil

    fittings.each {|item| orifice_id = item[:id] if item[:value] == 'Orifice' }

    orifice_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', orifice_id])

    #calculate flow elements sum
    flow_element_ids = []

    fittings.each do |item| 
      if item[:value].include?("Flow")
        flow_element_ids << item[:id] 
      end
    end

    flow_elements_dp_sum = 0.0
    self.suction_pipings.where({:fitting => flow_element_ids}).each do |f|
      flow_elements_dp_sum = flow_elements_dp_sum + f.delta_p
    end

    #add flow elements dp sum to orifice dp
    orifice_dp = orifice_dp + flow_elements_dp_sum


    equipment_id = nil
    fittings.each {|item| equipment_id = item[:id] if item[:value] == 'Equipment' }
    equipment_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', equipment_id])

    control_valve_id = nil
    fittings.each {|item| control_valve_id = item[:id] if item[:value] == 'Control Valve' }
    control_valve_dp = self.suction_pipings.sum(:delta_p, :conditions => ['fitting = ? ', control_valve_id])

    total_suction_dp =  self.suction_pipings.sum(:delta_p)

    fitting_dp = total_suction_dp - (equipment_dp + control_valve_dp + orifice_dp)

    unit_decimals = self.project.project_units

    self.update_attributes(
     :su_fitting_dP => fitting_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
     :su_equipment_dP => equipment_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
     :su_control_valve_dP => control_valve_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
     :su_orifice_dP => orifice_dp.round(unit_decimals["Pressure"]["Differential"][:decimal_places].to_i),
     :su_total_suction_dP => total_suction_dp.round(unit_decimals["Pressure"]["General"][:decimal_places].to_i),
     )
  end

  #determines the maximum pressure at discharge nozzle in discharge circuits
  #and updates the pressure at discharge nozzle at both centrifugal and reciprocating tabs
  def determine_design_circuit
    dps = {} 
    discharges = pump_sizing_discharges
    discharges.each do |pds|
      dps[pds.pressure_at_discharge_nozzle_dp] = pds.id
    end
    max_dp = dps.keys.max
    id = dps[max_dp]
    update_attributes(
      :selected_discharge_design_circuit => id,
      :cd_press_at_discharge_nozzle => max_dp,
      :rd_press_at_discharge_nozzle => max_dp
      )
    return id
  end

  def design_pump_centrifugal
    log = CustomLogger.new('pump_design_centrifugal')
    project = self.project
    show_info = false
    message = ""
    p2 = convert_to_base_unit(:cd_press_at_discharge_nozzle)
    p1 = convert_to_base_unit(:cd_press_at_suction_nozzle)
    density = convert_to_base_unit(:su_density)
    delta_p = p2 - p1
    diff_head = (144.0 * delta_p) / density
    design_factor = project.centrifugal_pump_design_safety_factor.to_i
    safety_factor = diff_head * (design_factor / 100.0)
    required_diff_head = diff_head + safety_factor

    log.info("P2 = #{p2}")
    log.info("P1 = #{p1}")
    log.info("Density = #{density}")
    log.info("DeltaP = #{delta_p}")
    log.info("DiffHead = #{diff_head}")
    log.info("DesignFactor = #{design_factor}")
    log.info("SafetyFactor = #{safety_factor}")
    log.info("RrequiredDiffHead = #{required_diff_head}")

  #determine NPSHA
  vapor_pressure = convert_to_base_unit(:su_vapor_pressure)
  npsha_delta_p = p1 - vapor_pressure
  npsha = (144.0 * npsha_delta_p) / density

  log.info("VaporP = #{vapor_pressure}")
  log.info("NPSHADeltaP = #{npsha_delta_p}")
  log.info("NPSHA = #{npsha}")

  #determine power required
  mass_flow_rate = convert_to_base_unit(:su_mass_flow_rate)
  volume_rate = (mass_flow_rate * 7.4805) / (density * 60.0)
  sg = density / 62.4
  hydraulic_power = (volume_rate * required_diff_head  * sg) / 3960.0
  efficiency = cd_efficiency / 100.0
  brake_horsepower = hydraulic_power / efficiency

  log.info("MassFlowRate = #{mass_flow_rate}")
  log.info("VolumeRate = #{volume_rate}")
  log.info("SG = #{sg}")
  log.info("HydraulicPower = #{hydraulic_power}")
  log.info("Efficiency = #{efficiency}")
  log.info("Brake HP = #{brake_horsepower}")

  #determine shutoff
  shutoff_factor = project.centrifugal_pump_shut_off_factor #form project
  shutoff_diff_p = delta_p * (1.0 + (shutoff_factor / 100.0))
  shutoff_head = required_diff_head * (1.0 + (shutoff_factor/100.0))
  max_suction = convert_to_base_unit(:su_max_pressure_at_suction_nozzle)
  shutoff_pressure = max_suction + shutoff_diff_p

  log.info("ShutOffFactor = #{shutoff_factor}")
  log.info("ShutOffDiffP = #{shutoff_diff_p}")
  log.info("ShutOffHead = #{shutoff_head}")
  log.info("MaxSuction = #{max_suction}")
  log.info("ShutOffPressure = #{shutoff_pressure}")

  #determine discharge temperature
  specific_heat_capacity = convert_to_base_unit(:su_specific_heat_capacity)
  temperature = convert_to_base_unit(:su_temperature)
  delta_t2 = (required_diff_head * ((1.0 / efficiency) -1.0)) / (778.0 * specific_heat_capacity)
  discharge_temp = temperature + delta_t2

  log.info("SpecificHeatCapacity = #{specific_heat_capacity}")
  log.info("SuctionTemp = #{temperature}")
  log.info("DeltaT2 = #{delta_t2}")
  log.info("DischargeTemp = #{discharge_temp}")

  if cd_compressible_liquid == 1
    discharge_density = convert_to_base_unit(:cd_density_at_discharge_nozzle)
    critical_pressure = convert_to_base_unit(:su_critical_pressure)
    delta_density = (discharge_density - density).abs
    percent_change_in_density = (delta_density/density) * 100.0
    percent_diff_critical_p = ((critical_pressure - p2)/p2) * 100.0

    log.info("DischargeDensity = #{discharge_density}")
    log.info("CriticalPressure = #{critical_pressure}")
    log.info("DeltaDensity = #{delta_density}")
    log.info("PercentChangeInDensity = #{percent_change_in_density}")
    log.info("PercentDiffCriticalP = #{percent_diff_critical_p}")

    compression_head = 1.155 * (p2 - p1) * ((1.0 / (discharge_density / 62.4)) + (1.0 / (density / 62.4)))
    ch_safety_factor = compression_head * (design_factor / 100.0)
    compression_head = compression_head + ch_safety_factor
    hydraulic_power = (volume_rate * compression_head * sg) / 3960.0
    brake_hp = hydraulic_power/efficiency

    log.info("CHSafetyFactor = #{ch_safety_factor}")
    log.info("CompressionHead = #{compression_head}")
    log.info("HydraulicPower = #{hydraulic_power}")
    log.info("Bake HP = #{brake_hp}")

    if percent_change_in_density > 10 or percent_diff_critical_p < 10.0 or delta_t2 > 10.0
      show_info = true
      message = "Non-Linear Change in Density with Change in Pressure Expected.\nAt the discharge conditions, the change in fluid density and other properties with pressure may not be linear. Equations implemented in this application for pump sizing may not be accurate.  Consultation with the pump vendor is required to properly size this centrifugal pump."
    end
  else
    density_at_discharge_nozzle = 0.0
    compression_head = 0.0
  end

  #assign calculated values to the model
  self.cd_hydraulic_hp = convert_to_project_unit(:cd_hydraulic_hp, hydraulic_power)
  self.cd_brake_horsepower = convert_to_project_unit(:cd_brake_horsepower, brake_hp)
  self.cd_temp_at_discharge_nozzle = convert_to_project_unit(:cd_temp_at_discharge_nozzle,discharge_temp)
  self.cd_differential_pressure = convert_to_project_unit(:cd_differential_pressure,delta_p)
  self.cd_differential_head = convert_to_project_unit(:cd_differential_head, diff_head)
  self.cd_shut_off_factor = project.centrifugal_pump_shut_off_factor
  self.cd_safety_factor = convert_to_project_unit(:cd_safety_factor,safety_factor)
  self.cd_required_differential_head =  convert_to_project_unit(:cd_differential_head, diff_head) + safety_factor
  self.cd_npsha = convert_to_project_unit(:cd_npsha, npsha)
  self.cd_required_compression_head = convert_to_project_unit(:cd_required_compression_head, compression_head)
  self.cd_flow_rate = convert_to_project_unit(:cd_flow_rate, volume_rate)
  self.cd_s_g = convert_to_project_unit(:cd_s_g,sg)
  self.cd_shut_off_head = convert_to_project_unit(:cd_shut_off_head, shutoff_head)
  self.cd_shut_off_pressure = convert_to_project_unit(:cd_shut_off_pressure, shutoff_pressure)
  self.cd_max_suction_pressure = convert_to_project_unit(:cd_max_suction_pressure, max_suction)
  self.cd_np_press_at_suction_nozzle = convert_to_project_unit(:cd_np_press_at_suction_nozzle,p1)
  #self.cd_efficiency = efficiency
  self.cd_vapor_pressure = convert_to_project_unit(:cd_vapor_pressure,vapor_pressure)
  self.save
  return {:show_info => show_info, :message => message}
end

def design_pump_reciprocation
 log = CustomLogger.new('design_pump_reciprocation')
 show_info = false
 message = ""
 project                = self.project
 no_of_cylinders        = rd_no_of_cylinders
 pd_type                = rd_stroke_action
 bore                   = convert_to_base_unit(:rd_bore)
 stroke                 = convert_to_base_unit(:rd_stroke)
 rod                    = convert_to_base_unit(:rd_rod_diameter)
 speed                  = rd_piston_speed
 leakage_factor         = rd_leakage_factor_s
 volume_ratio           = rd_volume_ratio_r
 uom                    = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
 barometric_pressure    = uom[:factor] * project.barometric_pressure
 mass_flow_rate         = convert_to_base_unit(:su_mass_flow_rate)
 temperature            = convert_to_base_unit(:su_temperature)
 pressure               = convert_to_base_unit(:su_pressure)
 suction_density        = convert_to_base_unit(:su_density)
 discharge_density      = convert_to_base_unit(:rd_density_at_discharge_nozzle)
 sg                     = discharge_density / 62.4
 specific_heat_capacity = convert_to_base_unit(:su_specific_heat_capacity)
 discharge_pressure     = convert_to_base_unit(:rd_press_at_discharge_nozzle)
 suction_pressure       = convert_to_base_unit(:rd_press_at_suction_nozzle)

 log.info("barometric_pressure = #{barometric_pressure}")
 log.info("CylinderNo = #{no_of_cylinders}")
 log.info("PDType = #{pd_type}")
 log.info("Bore = #{bore}")
 log.info("Stroke = #{stroke}")
 log.info("Rod Diameter = #{rod}")
 log.info("Speed = #{speed}")
 log.info("Leakage Factor = #{leakage_factor}")
 log.info("Volume Ratio = #{volume_ratio}")
 log.info("Barometric Pressure = #{barometric_pressure}")
 log.info("Mass Flow Rate = #{mass_flow_rate}")
 log.info("Temperature = #{temperature}")
 log.info("Pressure = #{pressure}")
 log.info("Suction Density = #{suction_density}")
 log.info("Discharge Density = #{discharge_density}")
 log.info("SG = #{sg}")
 log.info("SpecificHeatCapacity = #{specific_heat_capacity}")
 log.info("SuctionP = #{suction_pressure}")
 log.info("DischargeP = #{discharge_pressure}")
 pi = 3.14159265358979

   #area of rod
   arod = pi * (rod / 2.0) ** 2.0

   #area of piston
   abore = pi *(bore / 2.0) ** 2.0
   #determine pistion displacement
   log.info("Arod  = #{arod}")
   log.info("Abore = #{abore}")

   if pd_type == 'Single-Acting'
     piston_displacement = (abore * no_of_cylinders * stroke * speed) / 231.0
   elsif pd_type == 'Double-Acting'
     piston_displacement = ((2.0 * abore - arod) * no_of_cylinders * stroke * speed) / 231.0
   elsif pd_type == 'Double-Acting with Guided Piston'
     piston_displacement = (((2.0 * abore) - (2 * arod)) * no_of_cylinders * stroke * speed) / 231.0
   end

   log.info("PD = #{piston_displacement}")

   #determine volumetric efficiency
   vel = 1.0 - leakage_factor
   vedp = 1.0 - volume_ratio * (1.0 - (suction_density / discharge_density))
   vedov = (vel * vedp)

   log.info("VEl = #{vel}")
   log.info("VEdp = #{vedp}")
   log.info("VEdov = #{vedov}")

   #determine capcity based on discharge parameters
   qd = piston_displacement * vedov

   log.info("Qd = #{qd}")

   #determine differential head
   diff_pressure = discharge_pressure - suction_pressure
   diff_head = (144.0 * diff_pressure) / discharge_density
   design_factor  = project.positive_displacement_pump_design_safety_factor.to_f #from projet
   safety_factor = diff_head * (design_factor / 100.0)
   required_diff_head = diff_head + safety_factor
   efficiency =  project.positive_displacement_mechanical_efficiency.to_f / 100.0 #from project setup

   log.info("DiffPressure = #{diff_pressure}")
   log.info("DiffHead = #{diff_head}")
   log.info("DesignFactor = #{design_factor}")
   log.info("SafetyFactor = #{safety_factor}")
   log.info("RrequiredDiffHead = #{required_diff_head}")
   log.info("Efficiency1 = #{efficiency}")

   #determine discharge temperature
   delta_t = (required_diff_head * (( 1.0 / efficiency ) - 1.0)) / (778.0 * specific_heat_capacity)
   discharge_temp = temperature+delta_t
   hydraulic_power = (qd * required_diff_head * sg) / 3960.0
   brake_horsepower = hydraulic_power/efficiency

   log.info("DeltaT = #{delta_t}")
   log.info("DischargeT = #{discharge_temp}")
   log.info("HydraulicPower = #{hydraulic_power}")
   log.info("BrakeHP = #{brake_horsepower}")

   compression_head = 0.0

   #checkbox
   if rd_compressible_liquid
     log.info("---- include compressible liquid")
     critical_pressure = convert_to_base_unit(:su_critical_pressure)
     delta_density = (discharge_density - suction_density).abs
     percent_change_in_density = (delta_density/suction_density) * 100.0
     percent_diff_critical_pressure = ((critical_pressure - discharge_pressure) / discharge_pressure) * 100.0
     compression_head = 1.155 * (discharge_pressure - suction_pressure) * ((1.0 / (discharge_density / 62.4)) + (1.0 / (suction_density / 62.4)))
     ch_safety_factor = compression_head * (design_factor / 100.0)
     compression_head = compression_head + ch_safety_factor
     hydraulic_power = (qd * compression_head * sg) / 3960.0
     brake_horsepower = hydraulic_power/efficiency

     log.info("CriticalPressure = #{critical_pressure}")
     log.info("DeltaDensity = #{delta_density}")
     log.info("PercentChangeInDensity = #{percent_change_in_density}")
     log.info("PercentDiffCriticalP = #{percent_diff_critical_pressure}")
     log.info("CompressionHead = #{compression_head}")
     log.info("CHSafetyFactor = #{ch_safety_factor}")
     log.info("CompressionHead = #{compression_head}")
     log.info("HydraulicPower = #{hydraulic_power}")
     log.info("BrakeHP = #{brake_horsepower}")

     if percent_change_in_density > 10.0 or percent_diff_critical_pressure < 10.0 or delta_t > 10.0 
       message = "Non-Linear Change in Density with Change in Pressure Expected.\n At the discharge conditions, the change in fluid density and other properties with pressure may not be linear.  Equations implemented in this application for pump sizing may not be accurate.  Consultation with the pump vendor is required to properly size this reciprocating pump." 
       show_info = true
     end
   else
     pd_compression_head = 0.0
   end

   #determine NPSHA
   vapor_pressure = convert_to_base_unit(:rd_vapor_pressure)
   npsha_delta_p = suction_pressure - vapor_pressure
   npsha = (144 * npsha_delta_p) / suction_density

   log.info("-----------determine NPSHA")
   log.info("VaporP = #{vapor_pressure}")
   log.info("NPSHADeltaP = #{npsha_delta_p}")
   log.info("NPSHA = #{npsha}")

   #liquid acceleration
   acceleration_head = calculate_pump_acceleration_head
   npsha = npsha + acceleration_head

   log.info("AccelerationHead = #{acceleration_head}")
   log.info("NPSHA+AccelerationHead = #{npsha}")

   #save calculated values
   update_attributes(
     :rd_compression_head => convert_to_project_unit(:rd_compression_head,compression_head),
     :rd_rated_discharge_capacity => convert_to_project_unit(:rd_rated_discharge_capacity,qd),
     :rd_npsha => convert_to_project_unit(:rd_npsha, npsha),
     :rd_hydraulic_hp => convert_to_project_unit(:rd_hydraulic_hp,hydraulic_power),
     :rd_brake_horsepower => convert_to_project_unit(:rd_brake_horsepower,brake_horsepower),
     :rd_temp_at_discharge_nozzle => convert_to_project_unit(:rd_temp_at_discharge_nozzle,discharge_temp),
     :rd_differential_pressure => convert_to_project_unit(:rd_differential_pressure,diff_pressure),
     :rd_differential_head => convert_to_project_unit(:rd_differential_head,required_diff_head),
     :rd_acceleration_head => convert_to_project_unit(:rd_acceleration_head, acceleration_head),
     :rd_vapor_pressure => convert_to_project_unit(:rd_vapor_pressure,vapor_pressure),
     :rd_piston_displacement => convert_to_project_unit(:rd_piston_displacement,piston_displacement),
     :rd_volumetric_efficiency => (vedov * 100).round(2),
     :rd_mechanical_efficiency => project.positive_displacement_mechanical_efficiency.to_i
     )
return {:show_info => show_info, :message => message}
end


def calculate_pump_acceleration_head
  log = CustomLogger.new("pump_acceleration_head")
  pipeID = (0..1000).to_a
  pipeL = (0..1000).to_a
  pipeIDCount = (0..100).to_a
  pi = 3.14159265358979

  #determine volumetric flow rate
  density = convert_to_base_unit(:su_density)
  mass_flow_rate = convert_to_base_unit(:su_mass_flow_rate)
  volume_rate = (mass_flow_rate / (density * 3600))

  log.info("Density = #{density}")
  log.info("Mass Flow Rate = #{mass_flow_rate}")
  log.info("VolumeRate = #{volume_rate}")

  #determine constants
  n = rd_piston_speed
  c = rd_acc_head_factor_for_pump_type
  k = rd_acc_head_factor_for_fluid_compressibility
  g = 32.2

  #determine suction fitting count
  fitting_count = suction_pipings

  #determine number of unique pipe size
  uniq_pipe_ids = suction_pipings.collect {|p| p.pipe_id }.uniq

  sum_acceleration_head = 0.0

  #calculate acceleration head and sum for each uniq pipe size
  uniq_pipe_ids.each do |p|
    sum_pipe_length = suction_pipings.collect {|l| l.length if l.pipe_id == p}.compact.sum
    sum_pipe_length = convert_to_base_unit(:length, sum_pipe_length)
    #get current pipe iD value converted
    p = convert_to_base_unit(:pipe_id,p)

    area = (pi * (p / 2.0) ** 2.0)/ 144
    velocity = volume_rate / area

    v = velocity
    l = sum_pipe_length
    acceleration_head = (l * v * n * c) / (k * g)
    sum_acceleration_head = sum_acceleration_head + acceleration_head
  end
  return sum_acceleration_head
end

def equalize
  s = selected_discharge_design_circuit
  discharges = pump_sizing_discharges
  highest_pressure = pump_sizing_discharges.find(s).pressure_at_discharge_nozzle_dp

  warning = {:items => []}

  #measure unit values for decimal rounding 
  cf = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'General')

  discharges.each do |d|
   pressure_difference = highest_pressure - d.pressure_at_discharge_nozzle_dp

    #update fittings
    fittings = d.discharge_circuit_piping 

    #delta p calculation
    control_valve_fittings = []
    orifice_fittings = []

    fittings.each do |cp|
      fitting_type = PipeSizing.get_fitting_tag1(cp.fitting)[:value]
      if fitting_type == 'Orifice' || fitting_type.include?('Flow')
        orifice_fittings << cp
      elsif fitting_type == 'Control Valve'
        control_valve_fittings << cp
      end
    end

    total_fitting_count = control_valve_fittings.length + orifice_fittings.length
    final_pressure_difference = pressure_difference 

    if total_fitting_count > 1
      final_pressure_difference = pressure_difference / total_fitting_count
    end

    unless control_valve_fittings.length == 0
      control_valve_fittings.each do |f|
        f.update_attributes(:delta_p => f.delta_p + final_pressure_difference.round(cf[:decimals]))
      end
    end

    unless orifice_fittings.length == 0
      orifice_fittings.each do |f|
        f.update_attributes(:delta_p => f.delta_p + final_pressure_difference.round(cf[:decimals]))
      end
    end

    if total_fitting_count == 0
      warning[:true] = true
      war = {}
      war[:design_circuit_id] = d.id
      war[:warning] = "Circuit #{d.id} may require a control valve or orifice with the pressure drop of #{final_pressure_difference} to  equalize with the design circuit"
      warning[:items] << war
    end

  #inlet pressure calculation
  sum_of_delta_p = fittings.collect {|f| f.delta_p }.compact.sum
  sum_of_delta_p = 0.0 if sum_of_delta_p.nil?

  destination_pressure = d.destination_pressure

  fittings.each do |f|
    f.update_attributes(:inlet_pressure => (destination_pressure + sum_of_delta_p).round(cf[:decimals]))
    sum_of_delta_p = sum_of_delta_p - f.delta_p
  end

  control_valve_delta_p_sum = control_valve_fittings.collect { |f| f.delta_p }.compact.sum
  orifice_delta_p_sum = orifice_fittings.collect {|f| f.delta_p }.compact.sum

  #update discharges
  d.update_attributes(
    :pressure_at_discharge_nozzle_dp => d.pressure_at_discharge_nozzle_dp + pressure_difference,
    :control_valve_dp => control_valve_delta_p_sum,
    :orifice_dp => orifice_delta_p_sum
    )
end

#do the cv summary and fe summary
calculate_cv_summary
calculate_fe_summary('Liquid')
return warning
end

#calculate cvsummary and save the array in cvsummary attribute
def calculate_cv_summary
  log = CustomLogger.new('cv_summary')
  #find control valve fittings
  control_valve_fittings = []

  control_valve_id = 0

  #find the tag id for fitting type Control Valve
  PipeSizing.fitting1.each do |p|
    control_valve_id = p[:id] if p[:value] == 'Control Valve'
  end

  #currently using only fittings on the discharge side
  discharges = pump_sizing_discharges

  #place holder to track which design circuit a fitting belongs to
  fitting_to_discharge_mapping = {}

  discharges.each_with_index do |d,index|
    d.discharge_circuit_piping.collect do |f| 
      if f.fitting == control_valve_id
        control_valve_fittings << f 
        #update the mapping
        fitting_to_discharge_mapping[f.id] = index
      end
    end
  end

 #calculate CV for all control valve fittings
 cvs = []
 control_valve_fittings.each do |f|

  mass_flow_rate = convert_to_base_unit(:su_mass_flow_rate)
  percentage_flow = f.per_flow
  mass_flow_rate = mass_flow_rate * (percentage_flow / 100)
  density = f.density
  delta_p  = convert_to_base_unit(:delta_p,f.delta_p)

  q = (mass_flow_rate / density) * 0.124675325
  sg = density / 62.4
  cv = q * ((sg / delta_p) ** 0.5)

  log.info("-----tag --- #{f.fitting_tag}")
  log.info("mass_flow_rate = #{mass_flow_rate}")
  log.info("percentage_flow = #{percentage_flow}")
  log.info("density = #{density}")
  log.info("deltaP = #{delta_p}")
  log.info("Q = #{q}")
  log.info("SG = #{sg}")
  log.info("Cv = #{cv}")

  cvdp = self.project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Differential')
  cvcf = self.project.base_unit_cf(:mtype => 'Control valve cv', :msub_type => 'Dimensionless')

  #save cv in the fitting
  f.update_attributes(:ds_cv => cv.round(cvcf[:decimals]))


  #create a hash to to save
  s = {}
  s[:circuit_number] = fitting_to_discharge_mapping[f.id]
  s[:control_valve_tag] = f.fitting_tag
  s[:inlet_pressure] = f.inlet_pressure
  s[:outlet_pressure] = (f.inlet_pressure - f.delta_p).round(cvdp[:decimals])
  s[:cv_delta_p] = f.delta_p.round(cvdp[:decimals])
  s[:density] = convert_to_project_unit(:su_density, f.density)
  s[:cv] = cv.round(cvcf[:decimals])

  #array of all control valves
  cvs << s
end

update_attributes(:cv_summary => cvs)
return cvs
end


#calculate fesummary and save the array in fesummary attribute
def calculate_fe_summary(stream_phase)
  log = CustomLogger.new('calculate_fe_summary')

  #find orifice and flow element fittings
  orifice_and_flow_element_fittings = []
  orifice_and_fe_ids = []

  #find the tag id for fitting type orifice and flow element
  PipeSizing.fitting1.each do |p|
    orifice_and_fe_ids << p[:id] if p[:value].include?('Flow Element') || p[:value] == 'Orifice'
  end

  discharges = pump_sizing_discharges

  #place holder to track which discharge circuit a fitting belongs to
  fitting_to_discharge_mapping = {}

  discharges.each_with_index do |d,index|
    d.discharge_circuit_piping.collect do |f| 
      if orifice_and_fe_ids.include?(f.fitting)
        orifice_and_flow_element_fittings << f 
        fitting_to_discharge_mapping[f.id] = index
      end
    end
  end

  flow_rate    = (1..100).to_a
  co           = (0..10000).to_a
  y            = (0..10000).to_a
  beta         = (0..10000).to_a
  rounded_beta = (0..10000).to_a 
  
  vapor_k = su_mass_vapor_fraction

  #test values
  #mass_flow_rate = 50000
  #vapor_k = 1.35
  #viscosity = 0.012
  #density = 0.3653
  #barometric_pressure = 14.67
  #inlet_pressure = 135
  #outlet_pressure = 115

  p1 = 0.0
  p2 = 0.0
  barometric_pressure = 0.0

  cinf = 0.0
  b = 0.0
  n = 0.0

  fes = []

  message = ""

  orifice_and_flow_element_fittings.each do |f|
    density = f.density
    viscosity = f.viscosity
    mass_flow_rate = f.mass_flow_rate
    fitting_type = PipeSizing.get_fitting_tag1(f.fitting)[:value]
    orifice_type = " "
    orifice_type1 = " "

    orifice_d = 0.0
    pipe_id = convert_to_base_unit(:pipe_id, f.pipe_id)
    delta_p = convert_to_base_unit(:delta_p, f.delta_p)
    d = f.pipe_size.to_f

    #incase the fitting type is 'Orifice' we need to determine orifice type
    if fitting_type == 'Orifice'
      default_orifice_type = project.restriction_orifice_meter_default_type
      if default_orifice_type == "Flange Taps"
        if d > 2.3
          orifice_type == "Flow Element - Orifice Plate (Flange Tap with D > 2.3 inches)"
        elsif d >= 2.0 and d <= 2.3
          orifice_type == "Flow Element - Orifice Plate (Flange Tap with D >= 2 and D <= 2.3 inches)"
        end
      elsif default_orifice_type == "Corner Taps"
        orifice_type = "Flow Element - Orifice Plate (Corner Tap)"
      elsif default_orifice_type == "Radius Taps"
        orifice_type = "Flow Element - Orifice Plate (D and D/2 Taps)"
      elsif default_orifice_type == "Pipe Taps"
        orifice_type = "Flow Element - Orifice Plate (2D and 8D Taps or Pipe Taps)"
      end
    else
      orifice_type = fitting_type
    end

    if stream_phase == 'Vapor'
      uom  = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
      barometric_pressure  = uom[:factor] * project.barometric_pressure
      p1 = f.inlet_pressure + barometric_pressure
      p2 = f.outlet_pressure + barometric_pressure
    end

    co[0] = 0.61
    y[0] = 1.0

    log.info("Density = #{density}")
    log.info("MassFlowRate = #{mass_flow_rate}")
    log.info("Viscosity = #{viscosity}")
    log.info("OrificeType = #{orifice_type}")
    log.info("pipeID  = #{pipe_id}")
    log.info("DeltaP = #{delta_p}")
    log.info("PipeSize = #{d}")
    log.info("StreamPhase = #{stream_phase}")
    log.info("MassFlowRate = #{mass_flow_rate}")
    log.info("VaporK = #{vapor_k}")
    log.info("P1 = #{p1}")
    log.info("P2 = #{p2}")

    (1..10000).each do |i|
      #x = (0.000000279926 * (mass_flow_rate ** 2)) / ((pipe_id ** 4.0) * (y[i - 1] ** 2) * (co[i - 1] ** 2) * liquid_density * delta_p)
      x = (0.000000279926 * (mass_flow_rate ** 2)) / ((pipe_id ** 4.0) * (y[i - 1] ** 2) * (co[i - 1] ** 2) * density * delta_p)
      beta[i] = (x / (1.0 + x)) ** (1.0 / 4.0)
      #nred = (6.31595 * mass_flow_rate) / (pipe_id * liquid_viscosity)
      nred = (6.31595 * mass_flow_rate) / (pipe_id * viscosity)
      nreb = nred / beta[i] 

      #Determine Discharge Coefficient (Infinitity) for Equation 10-10, Darby
     if orifice_type == "Flow Element - Orifice Plate (Corner Tap)"
      cinf = 0.5959 + (0.0312 * (beta[i] ** 2.1)) - (0.184 * (beta[i] ** 8))
      b = 91.71 * (beta[i] ** 2.5)
      n=0.75
      orifice_type1 = "Corner Taps"
    elsif  orifice_type == "Flow Element - Orifice Plate (Flange Tap with D > 2.3 inches)" || orifice_type == "Flow Element - Orifice Plate (Flange Tap with D > 58.4 millimeters)"
      cinf = 0.5959 + (0.0312 * (beta[i] ** 2.1)) - (0.184 * (beta[i] ** 8)) + (0.09 * ((beta[i] ** 4) / (pipe_id * (1 - (beta[i] ** 4))))) - (0.0337 * ((beta[i] ** 3) / pipe_id))
      b = 91.71 * (beta[i] ** 2.5)
      n=0.75
      orifice_type1 = "Flange Taps"
    elsif orifice_type == "Flow Element - Orifice Plate (Flange Tap with D >= 2 and D <= 2.3 inches)" || orifice_type == "Flow Element - Orifice Plate (Flange Tap with D >=50.8 and D <= 58.4 millimeters)"
      cinf = 0.5959 + (0.0312 * (beta[i] ** 2.1)) - (0.184 * (beta[i] ** 8)) +  (0.039 * ((beta[i] ** 4) / (1 - beta[i] ** 4))) - (0.0337 * ((beta[i] ** 3) / pipe_id))
      b = 91.71 * (beta[i] ** 2.5)
      n=0.75
      orifice_type1 = "Flange Taps"
    elsif orifice_type == "Flow Element - Orifice Plate (D and D/2 Taps) or Radius Taps"
      cinf = 0.5959 + (0.0312 * (beta[i] ** 2.1)) - (0.184 * (beta[i] ** 8)) + (0.039 * ((beta[i] ** 4) / (1 - beta[i] ** 4))) - (0.0158 * (beta[i] ** 3))
      b = 91.71 * (beta[i] ** 2.5)
      n = 0.75
      orifice_type = "Radius Taps"
      elsif orifice_type ==  "Flow Element - Orifice Plate (2D and 8D Taps or Pipe Taps)"
      cinf = 0.5959 + (0.461 * (beta[i] ** 2.1)) + (0.48 * (beta[i] ** 8)) + (0.039 * ((beta[i] ** 4) / (1 - (beta[i] ** 4))))
      b = 91.71 * (beta[i] ** 2.5)
      n = 0.75
      orifice_type1 = "Pipe Taps"
    elsif orifice_type == "Flow Element - Venturi (Machined Inlet)"
      cinf = 0.995
      b = 0
      n = 0
      orifice_type1 = "Machine Inlet"
    elsif orifice_type == "Flow Element - Venturi (Rough Cast Inlet)"
      cinf = 0.984
      b = 0
      n = 0
      orifice_type1 = "Rough Cast"
    elsif orifice_type == "Flow Element - Venturi (Rough Welded Sheet - Iron Inlet)"
      cinf = 0.985
      b = 0
      n = 0
      orifice_type1 = "Rough Welded Sheet Iron Inlet"
    elsif orifice_type == "Flow Element - Nozzle (ASME Long Radius)"
      cinf = 0.9975
      b = -6.53 * (beta[i] ** 0.5)
      n = 0.5
      orifice_type1 = "ASME"
    elsif orifice_type == "Flow Element - Nozzle (ISA)"
      cinf = 0.99 - (0.2262 * (beta[i] ** 4.1))
      b = 1708 - (8936 * beta[i]) + (19779 * (beta[i] ** 4.7))
      n = 1.15
      orifice_type1 = "ISA"
    elsif orifice_type == "Flow Element - Nozzle (Venturi Nozzle - ISA Inlet)"
      cinf = 0.9858 - (0.195 * (beta[i] ** 4.5))
      b = 0
      n = 0
      orifice_type1 = "Venturi Nozzle"
    elsif orifice_type == "Flow Element - Universal Venturi Tube"
      cinf = 0.9797
      b = 0
      n = 0
      orifice_type1 = "Universal Venturi Tube"
    elsif orifice_type == "Flow Element - Lo-Loss Tube"
      cinf = 1.05 - (0.417 * beta[i]) + (0.564 * (beta[i] ** 2)) - (0.514 * (beta[i] ** 3))
      b = 0
      n= 0
      orifice_type1 = "Lo-Loss"
    end

    cd = 0.0


    #Determine Discharge Coefficient
    if ["Radius Taps","Corner Taps","Flange Taps"].include?(orifice_type1)
      if d >= 2.0 && d <= 36.0
        if beta[i] >= 0.2 && beta[i] <= 0.75
          if nred >= 10.0 ** 4 && nred <= 10.0 ** 7
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
          message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for (#{f.fitting_tag}). Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
        message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for (#{f.fitting_tag}). Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Pipe Taps"
      if d >= 2 && d <= 36
        if beta[i] >= 0.2 && beta[i] <= 0.75
          if nred >= (10 ** 4) && nred <= (10 ** 7)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for (#{f.fitting_tag}).  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
            message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for (#{f.fitting_tag}). Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Machine Inlet"
      if d >= 2 && d <= 10
        if beta[i] >= 0.4 && beta[i] <= 0.75
          if nred >= (2 * 10 ** 5) && nred <= (10 ** 6)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
            message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Rough Cast"
      if d >= 4 && d <= 32
        if beta[i] >= 0.3 && beta[i] <= 0.75
          if nred >= (2 * (10 ** 5)) && nred <= (10 ** 6)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
            message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Rough Welded Sheet Iron Inlet"
      if d >= 8 && d <= 48
        if beta[i] >= 0.4 && beta[i] <= 0.7
          if nred >= (2 * (10 ** 5)) && nred <= (10 ** 6)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
            message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "ASME"
      if d >= 2 && d <= 16
        if beta[i] >= 0.25 && beta[i] <= 0.75
          if nred >= (10 ** 4) && nred <= (10 ** 7)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
           message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "ISA"
      if d >= 2 && d <= 20
        if beta[i] >= 0.3 && beta[i] <= 0.75
          if nred >= (10 ** 5) && nred <= (10 ** 7)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
           message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Venturi Nozzle"
      if d >= 3 && d <= 20
        if beta[i] >= 0.3 && beta[i] <= 0.75
          if nred >= (2 * (10 ** 5)) && nred <= (2 * (10 ** 6))
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
           message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Universal Venturi Tube"
      if d >= 3
        if beta[i] >= 0.2 && beta[i] <= 0.75
          if nred >= 7.5 * (10 ** 4)
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
           message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    elsif orifice_type1 == "Lo-Loss"
      if d >= 3 && d <= 120
        if beta[i] >= 0.35 && beta[i] <= 0.85
          if nred >= (1.25 * (10 ** 5)) && nred <= (3.5 * (10 ** 6))
            cd = cinf + (b / (nred ** n))
          else
            message = "The pipe Reynolds Number falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}.  Therefore, the Orifice Diameter estimated may not be accurate."
          end
        else
           message = "The beta value falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
        end
      else
          message = "The pipe size falls outside the applicable and accuracy range for this type of flow element (#{orifice_type1}) selected for #{f.fitting_tag}. Therefore, the Orifice Diameter estimated may not be accurate."
      end
    end

    cd = cinf + (b / (nred ** n))

    co[i] = cd / (1 - (beta[i] ** 4)) ** 0.5

    part1 = 0.0
    part2 = 0.0
    part3 = 0.0

    if stream_phase == 'Vapor'
      if ["Radius Taps","Corner Taps","Flange Taps"].include?(orifice_type1)
        part2 = (0.351 + (0.256 * beta[i] ** 4) + (0.93 * beta[i] ** 8))
        part3 = 1 - ((p2 / p1) ** (1 / vapor_k))
        y[i] = 1 - (part2 * part3) 
      elsif ["Machine Inlet", "Rough Cast", "Rough Welded Sheet Iron Inlet", "ASME", "ISA", "Venturi Nozzle"].include?(orifice_type1)
        part1 = (vapor_k * ((p2 / p1)  ** (2 / vapor_k))) / (vapor_k - 1)
        part2 = (1 - beta[i] ** 4) / (1 - ((beta[i] ** 4) * ((p2 / p1) ** (2 / vapor_k))))
        part3 = (1 - ((p2 / p1) ** ((vapor_k - 1) / vapor_k))) / (1 - (p2 / p1))
        y[i] = (part1 * part2 * part3) ** 0.5 
      end
    elsif stream_phase == 'Liquid'
      y[i] = 1
    elsif stream_phase == 'Two  Phase'
    end

    break_i_loop = false

    if beta[i].round(7) == beta[i-1].round(7)
      orifice_d = beta[i] * pipe_id
      break_i_loop = true
    end

    if break_i_loop
      log.info("orifice_type1 = #{orifice_type1}")
      log.info("---------iteration i = #{i}")
      log.info("----------- i = #{i}")
      log.info("----------- X = #{x}")
      log.info("----------- beta[i] = #{beta[i]}")
      log.info("----------- cinf = #{cinf}")
      log.info("----------- b = #{b}")
      log.info("----------- n = #{n}")
      log.info("----------- part1 = #{part1}")
      log.info("----------- part2 = #{part2}")
      log.info("----------- part3 = #{part3}")
      log.info("----------- y[i] = #{y[i]}")
      log.info("----------- y[i-1] = #{y[i-1]}")
      log.info("----------- co[i-1] = #{co[i-1]}")
      log.info("----------- nreb = #{nreb}")
      log.info("----------- nred = #{nred}")
      log.info("----------- beta[i] = #{beta[i]}")
      orifice_d = convert_to_project_unit(:pipe_id, orifice_d)
      log.info("OrificeDiameter = #{orifice_d}")
    end
    break if break_i_loop
  end  #i loop

  cvdp = self.project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Differential')

  fe = {}
  fe[:circuit_number] = fitting_to_discharge_mapping[f.id]
  fe[:flow_element_tag] = f.fitting_tag
  fe[:inlet_pressure] = f.inlet_pressure
  fe[:outlet_pressure] = (f.inlet_pressure - f.delta_p).round(cvdp[:decimals])
  fe[:fe_delta_p] = f.delta_p.round(cvdp[:decimals])
  fe[:density] = convert_to_project_unit(:su_density, f.density)
  fe[:diameter] = orifice_d
  fe[:message] = message
  fes << fe
  f.update_attributes(:ds_cv => orifice_d)
end  #fitting loop

update_attributes(:fe_summary => fes)
return fes
end

def pump_curve
  pipe_id                    = (1..1000).to_a
  length                     = (1..1000).to_a
  flow_percentage            = (1..1000).to_a
  reynold_number             = (1..1000).to_a
  ft                         = (1..1000).to_a
  kfi                        = (1..1000).to_a
  kff                        = (1..1000).to_a
  kfper_diameter             = (1..1000).to_a
  dover_di                   = (1..1000).to_a
  elevation                  = (1..1000).to_a
  pressure_drop              = (1..1000).to_a
  fittings                   = (1..1000).to_a
  fitting_dp                 = (1..1000).to_a
  fitting_circuit            = (1..1000).to_a
  pipe_change_circuit        = (1..1000).to_a
  nre                        = (1..1000).to_a
  f                          = (1..1000).to_a
  kfii                       = (1..1000).to_a
  dover_dii                  = (1..1000).to_a
  kfd                        = (1..1000).to_a
  pump_differential_pressure = (1..100) .to_a
  pi = 3.14159265358979

  log = CustomLogger.new('pump_curve')

  uom  = project.base_unit_cf(:mtype => 'Pressure', :msub_type => 'Absolute')
  barometric_pressure  = uom[:factor] * project.barometric_pressure

  pipe_roughness = convert_to_base_unit(:su_pipe_roughness)
  e = pipe_roughness / 12

  density = convert_to_base_unit(:su_density)
  viscosity = convert_to_base_unit(:su_viscosity)
  mass_flow_rate = convert_to_base_unit(:su_mass_flow_rate)
  upstream_pressure = convert_to_base_unit(:su_pressure)

  log.info("converted density = #{density}")
  log.info("converted viscosity = #{viscosity}")
  log.info("converted mass flow rate = #{mass_flow_rate}")
  log.info("converted upstream_pressure = #{upstream_pressure}")

  #find the selected design circuit and get pressure at discharge nozzle
  destination_pressure = pump_sizing_discharges.find(selected_discharge_design_circuit).destination_pressure
  destination_pressure = convert_to_base_unit(:destination_pressure, destination_pressure)

  log.info("converted destination pressure = #{destination_pressure}")

  #Determine Volumetric Flow Rate
  normal_volume_rate = (mass_flow_rate / density) * (7.4805 / 60)
  max_volume_rate = normal_volume_rate * 1.5

  #count number of points to be determined
  cps = centrifugal_pumps
  no_of_points = cps.length

  interval_volume_rate = (max_volume_rate / no_of_points).round(0)

  log.info("interval_volume_rate = #{interval_volume_rate}")

  cps.each_with_index do |cp,i|
    log.info("------ iteration ------- i -------- #{i}")

    if i == 0
      upstream_head = upstream_pressure * (144.0 / density)
      destination_head = destination_pressure * (144 / density)
      sum_of_suction_elevation = suction_pipings.collect {|p| p.elev }.compact.sum
      sum_of_suction_elevation = convert_to_base_unit(:elevation, sum_of_suction_elevation)

      #selected design circuit
      discharge = pump_sizing_discharges.find(selected_discharge_design_circuit)
      sum_of_discharge_elevation = discharge.discharge_circuit_piping.collect {|p| p.elev }.compact.sum
      sum_of_discharge_elevation = convert_to_base_unit(:elevation, sum_of_discharge_elevation)

      suction_side_diff_head = upstream_head - sum_of_suction_elevation
      discharge_side_diff_head = destination_head +sum_of_discharge_elevation 
      pump_differential_head = discharge_side_diff_head - suction_side_diff_head

      capacity = 0.0

      log.info("Pump Differential Head (system loss) = #{pump_differential_head}")
      pump_differential_head = convert_to_project_unit(:cd_differential_head, pump_differential_head)
      log.info("converted Pump Differential Head (system loss) = #{pump_differential_head}")
    else
      volume_rate = interval_volume_rate * i

      final_volume_rate = volume_rate

      relief_rate = (volume_rate * density * 60) / 7.4805

      log.info("VolumeRate = #{volume_rate}")
      log.info("ReliefRate = #{relief_rate}")
      #determine suction system pressure drop

    ################ suction side hydraulics ###############
    pipeID          = (1..100).to_a
    length          = (1..100).to_a
    flow_percentage = (1..100).to_a
    reynold_number  = (1..100).to_a
    ft              = (1..100).to_a
    kfi             = (1..100).to_a
    doverdi         = (1..100).to_a
    nre             = (1..100).to_a
    kfii            = (1..100).to_a
    kfd             = (1..100).to_a
    f               = (1..100).to_a
    kff             = (1..100).to_a
    doverdii        = (1..100).to_a
    elevation       = (1..100).to_a
    pressure_drop   = (1..100).to_a

    #this code is copied from suction side hydraulics
    count           = suction_pipings.size  

    total_suction_system_dp = 0.0

    (0..count-1).each do |p|
      log.info("-------- fitting iteration nn --------#{p}")
      skip_count_loop = false
      circuit_piping = suction_pipings[p]

      fitting_type = PipeSizing.get_fitting_tag1(circuit_piping.fitting)[:value]
      log.info("fitting type = ---------- #{fitting_type} ----------")

      pipe_size = circuit_piping.pipe_size
      pipe_schedule = circuit_piping.pipe_schedule
      pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size,pipe_schedule)
      pipeID[p]  = convert_to_base_unit(:pipe_id,circuit_piping.pipe_id)

      if suction_pipings[p+1].nil?
        pipeID[p+1] = convert_to_base_unit(:pipe_id,suction_pipings[p].pipe_id)
      else
        pipeID[p+1] = convert_to_base_unit(:pipe_id,suction_pipings[p+1].pipe_id)
      end

      d = pipeID[p]
      d1 = pipeID[p]
      d2 = pipeID[p+1]

      pipeID[p] = pipeID[p] / 12.0
      pipeID[p+1] = pipeID[p+1] / 12.0

      if circuit_piping.length.nil?
        length[p]  = 0.0
      else
        length[p]  = convert_to_base_unit(:length,circuit_piping.length)
      end

      flow_percentage[p] = circuit_piping.per_flow
      cv = circuit_piping.ds_cv
      dorifice = convert_to_base_unit(:dorifice, circuit_piping.ds_cv) if !circuit_piping.ds_cv.nil?
      doverd = circuit_piping.ds_cv

      if circuit_piping.delta_p.nil?
        delta_p  = 0.0
      else
        delta_p  = convert_to_base_unit(:delta_p, circuit_piping.delta_p)
      end

      log.info("pipeID[p] = #{pipeID[p]}")
      log.info("length[p] = #{length[p]}")
      log.info("flow_percentage[p] = #{flow_percentage[p]}")
      log.info("cv = #{cv}")
      log.info("dorifice = #{dorifice}")
      log.info("P drop = #{delta_p}")

      relief_rate_0 = mass_flow_rate * (flow_percentage[p] / 100)
      volume_rate_0 = relief_rate_0 / density

      log.info("ReliefRate0 = #{relief_rate_0}")
      log.info("VolumeRate0 = #{volume_rate_0}")

      relief_rate_1 = relief_rate * (flow_percentage[p]/100)
      log.info("relief rate 1 = #{relief_rate_1}")

      volume_rate = relief_rate_1/density
      log.info("volume_rate = #{volume_rate}")
      log.info("pipeID[p] = #{pipeID[p]}")

      p_drop = delta_p
      p_drop = p_drop * ((volume_rate / volume_rate_0) ** 2) if !p_drop.nil?

      log.info("PDrop = #{p_drop}")

      nre[p] = (0.52633 * relief_rate_1) / (pipeID[p] * viscosity)
      log.info("nre[nn] = #{nre[p]}")

      a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 0.9) + (0.27 * (e / pipeID[p]))))) ** 16.0 
      b = (37530.0 / nre[p]) ** 16.0
      f[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 

      log.info("A = #{a}")
      log.info("B = #{b}")
      log.info("f[nn] = #{f[p]}")

      fd = 4.0 * f[p]
      nreynolds = nre[p]

      log.info("d = #{d}")
      log.info("d1 = #{d1}")
      log.info("d2 = #{d2}")

      kf = 0.0

      if fitting_type == 'Pipe'
        kf = 4.0 * f[p] * (length[p]/pipeID[p])
      elsif  fitting_type == 'Equipment' and !p_drop.nil?
       pressure_drop[p] = p_drop
       total_suction_system_dp = total_suction_system_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type == "Control Valve" and !p_drop.nil?
       pressure_drop[p] = p_drop
       total_suction_system_dp = total_suction_system_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type == "Orifice" and !p_drop.nil?
       pressure_drop[p] = p_drop
       total_suction_system_dp = total_suction_system_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type.include?("Flow") and !p_drop.nil?
       pressure_drop[p] = p_drop
       total_suction_system_dp = total_suction_system_dp + pressure_drop[p]
       skip_count_loop = true

     elsif  fitting_type == 'Equivalent length' and !p_drop.nil? 
       pressure_drop[p] = p_drop
       total_suction_system_dp = total_suction_system_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type == 'Line Segment' and !p_drop.nil?
       pressure_drop[p] = p_drop
       total_suction_system_dp = total_suction_system_dp + pressure_drop[p]
       skip_count_loop = true

     elsif fitting_type == 'Change Properties to Stream' and !p_drop.nil?
       spc = circuit_piping.stream_property_changer
       density = convert_to_base_unit(:su_density,spc.liquid_density)
       log.info("converted density = #{density}")
       viscosity = convert_to_base_unit(:su_viscosity,spc.liquid_viscosity)
       log.info("converted viscosity = #{viscosity}")

     else 
       rec = PipeSizing.resistance_coefficient(fitting_type,nreynolds,d,d1,d2,cv,doverd)
       kf = rec[:kf]
       doverd = rec[:dover_d]
     end

     log.info("kf = #{kf}")

     kfii[p] = kf
     doverdii[p] = doverd

     #save density, viscosity, and mass flow rate specific to fitting
     #circuit_piping.update_attributes(:density => density, :mass_flow_rate => relief_rate_1)

    if skip_count_loop
        log.info("pressure_drop[nn] = #{pressure_drop[p]}")
        log.info("total suction syste dp = #{total_suction_system_dp}")
    end

     next if skip_count_loop

     kfd[p] = kfii[p] / ((pipeID[p]) ** 4.0)

    #pipeID[p+1] = pipeID[p] / 12.0 if p == count.size

    log.info("pipeID[nn+1] = #{pipeID[p+1]}")

    nre[p+1] = (0.52633 * relief_rate_1) / (pipeID[p+1] * viscosity)

    log.info("nre[nn+1] = #{nre[p+1]}")

      #select Kinetic Energy Correction Factor
      alpha1 = 0.0
      alpha2 = 0.0
      if nre[p] <= 2000.0
        alpha1 = 2.0
      elsif nre[p] > 2000.0 and nre[p] < 10.0 ** 7.0
        alpha1 = 1.0
      elsif nre[p] > 10.0 ** 7.0
        alpha1 = 0.85
      end

      if nre[p+1] <= 2000.0
        alpha2 = 2.0
      elsif nre[p+1] > 2000.0 and nre[p+1] < 10.0 ** 7.0
        alpha2 = 1.0
      elsif nre[p+1] > 10.0 ** 7.0
        alpha2 = 0.85
      end

      log.info("alpha1 = #{alpha1}")
      log.info("alpha2 = #{alpha2}")

      kinetic_correction1 = alpha1 / pipeID[p] ** 4.0
      kinetic_correction2 = alpha2 / pipeID[p+1] ** 4.0

      if !['Expansion','Contraction','Sudden Expansion','Sudden Contraction'].include?(fitting_type)
        kinetic_correction1 = 0.0
        kinetic_correction2 = 0.0
      end

      log.info("kinetic_correction1 = #{kinetic_correction1}")
      log.info("kinetic_correction2 = #{kinetic_correction2}")
      log.info("volume_rate = #{volume_rate}")
      log.info("kfd[p] = #{kfd[p]}")

      #Kinetic Energy + Frictional Loss
      sumof_ke_and_ef = (0.810569 * volume_rate ** 2.0) * (kfd[p] + kinetic_correction2 - kinetic_correction1)

      log.info("SumofKEandEf = #{sumof_ke_and_ef}")

      #Potential Energy
      if circuit_piping.elev.nil?
        elevation[p] = 0.0
      else
        elevation[p] = convert_to_base_unit(:elevation,circuit_piping.elev)
      end

      pe  = 4.1698 * 10.0 **  8.0 * elevation[p]  

      log.info("elevation[nn] = #{elevation[p]}")
      log.info("PE = #{pe}")

      pressure_drop[p] = density * ((sumof_ke_and_ef + pe) / (6.00444 * 10.0 ** 10.0)) 

      log.info("pressure_drop[nn] = #{pressure_drop[p]}")

      total_suction_system_dp  = total_suction_system_dp + pressure_drop[p] 
      log.info("total suction syste dp = #{total_suction_system_dp}")

      #circuit_piping.update_attributes(:delta_p => pd)
    end #suction side hydraulics loop

  ########### start discharge side hydraulics  #########
  total_discharge_system_dp = 0.0

   #get the selected circuit
   discharge = pump_sizing_discharges.find(selected_discharge_design_circuit)

   suction_pipings = discharge.discharge_circuit_piping
   count = suction_pipings.size

   (0..count-1).each do |p|
    log.info("-------- fitting iteration nn --------#{p}")
    skip_count_loop = false
    circuit_piping = suction_pipings[p]

    fitting_type = PipeSizing.get_fitting_tag1(circuit_piping.fitting)[:value]
    log.info("fitting type = ---------- #{fitting_type} ----------")

    pipe_size = circuit_piping.pipe_size
    pipe_schedule = circuit_piping.pipe_schedule

    pipe_diameter = PipeSizing.determine_pipe_diameter(pipe_size,pipe_schedule)
    pipeID[p]  = convert_to_base_unit(:pipe_id,circuit_piping.pipe_id)

    if suction_pipings[p+1].nil?
      pipeID[p+1] = convert_to_base_unit(:pipe_id,suction_pipings[p].pipe_id)
    else
      pipeID[p+1] = convert_to_base_unit(:pipe_id,suction_pipings[p+1].pipe_id)
    end

    d = pipeID[p]
    d1 = pipeID[p]
    d2 = pipeID[p+1]

    pipeID[p] = pipeID[p] / 12.0
    pipeID[p+1] = pipeID[p+1] / 12.0

    if circuit_piping.length.nil?
      length[p]  = 0.0
    else
      length[p]  = convert_to_base_unit(:length,circuit_piping.length)
    end

    flow_percentage[p] = circuit_piping.per_flow

    cv = circuit_piping.ds_cv
    dorifice = convert_to_base_unit(:dorifice, circuit_piping.ds_cv) if !circuit_piping.ds_cv.nil?
    doverd = circuit_piping.ds_cv

    if circuit_piping.delta_p.nil?
      delta_p  = 0.0
    else
      delta_p  = convert_to_base_unit(:delta_p,circuit_piping.delta_p)
    end

    log.info("dorifice = #{dorifice}")
    log.info("pipeID[p] = #{pipeID[p]}")
    log.info("length[p] = #{length[p]}")
    log.info("flow_percentage[p] = #{flow_percentage[p]}")
    log.info("cv = #{cv}")
    log.info("dorifice = #{dorifice}")
    log.info("P drop = #{delta_p}")

    relief_rate_0 = mass_flow_rate * (flow_percentage[p] / 100)
    volume_rate_0 = relief_rate_0 / density

    log.info("ReliefRate0 = #{relief_rate_0}")
    log.info("VolumeRate0 = #{volume_rate_0}")

    relief_rate_1 = relief_rate * (flow_percentage[p]/100)
    log.info("relief rate 1 = #{relief_rate_1}")

    volume_rate = relief_rate_1 / density

    log.info("volume_rate = #{volume_rate}")
    log.info("pipeID[p] = #{pipeID[p]}")

    p_drop = delta_p

    p_drop = p_drop * ((volume_rate / volume_rate_0) ** 2) if !p_drop.nil?

    log.info("PDrop = #{p_drop}")
    nre[p] = (0.52633 * relief_rate_1) / (pipeID[p] * viscosity)
    log.info("nre[nn] = #{nre[p]}")

    a = (2.457 * Math.log(1.0 / (((7.0 / nre[p]) ** 0.9) + (0.27 * (e / pipeID[p]))))) ** 16.0 
    b = (37530.0 / nre[p]) ** 16.0
    f[p] = 2.0 * ((8.0 / nre[p]) ** 12.0 + (1.0 / ((a + b) ** (3.0 / 2.0)))) ** (1.0 / 12.0) 

    log.info("A = #{a}")
    log.info("B = #{b}")
    log.info("f[nn] = #{f[p]}")

    fd = 4.0 * f[p]
    nreynolds = nre[p]

    log.info("nreynolds = #{nreynolds}")
    log.info("d = #{d}")
    log.info("d1 = #{d1}")
    log.info("d2 = #{d2}")

    kf = 0.0

    if fitting_type == 'Pipe'
      kf = 4.0 * f[p] * (length[p]/pipeID[p])
    elsif  fitting_type == 'Equipment' and !p_drop.nil?
     pressure_drop[p] = p_drop
     total_discharge_system_dp = total_discharge_system_dp + p_drop
     skip_count_loop = true

   elsif fitting_type == "Control Valve" and !p_drop.nil?
     pressure_drop[p] = p_drop
     total_discharge_system_dp = total_discharge_system_dp + p_drop
     skip_count_loop = true

   elsif fitting_type == "Orifice" and !p_drop.nil?
     pressure_drop[p] = p_drop
     total_discharge_system_dp = total_discharge_system_dp + p_drop
     skip_count_loop = true

   elsif fitting_type.include?("Flow") and !p_drop.nil?
     pressure_drop[p] = p_drop
     total_discharge_system_dp = total_discharge_system_dp + p_drop
     skip_count_loop = true

   elsif  fitting_type == 'Equivalent length' and !p_drop.nil? 
     pressure_drop[p] = p_drop
     total_discharge_system_dp = total_discharge_system_dp + p_drop
     skip_count_loop = true

   elsif fitting_type == 'Line Segment' and !p_drop.nil?
     pressure_drop[p] = p_drop
     total_discharge_system_dp = total_discharge_system_dp + p_drop
     skip_count_loop = true

   elsif fitting_type == 'Change Properties to Stream' and !p_drop.nil?
     spc = circuit_piping.stream_property_changer

     density = convert_to_base_unit(:su_density,spc.liquid_density)
     log.info("converted density = #{density}")

     viscosity = convert_to_base_unit(:su_viscosity,spc.liquid_viscosity)
     log.info("converted viscosity = #{viscosity}")
   else 
     rec = PipeSizing.resistance_coefficient(fitting_type,nreynolds,d,d1,d2,cv,doverd,dorifice,project)
     kf = rec[:kf]
     doverd = rec[:dover_d]
   end

   log.info("kf = #{kf}")
   log.info("doverd = #{doverd}")

   kfii[p] = kf
   doverdii[p] = doverd


    if skip_count_loop
      log.info("pressure_drop[nn] = #{pressure_drop[p]}") 
      log.info("total discharge system dp = #{total_discharge_system_dp}")
    end

    next if skip_count_loop

    kfd[p] = kfii[p] / ((pipeID[p]) ** 4.0)

    #pipeID[p+1] = pipeID[p] / 12.0 if p == count.size

    log.info("pipeID[nn+1] = #{pipeID[p+1]}")

    nre[p+1] = (0.52633 * relief_rate_1) / (pipeID[p+1] * viscosity)

    log.info("nre[nn+1] = #{nre[p+1]}")

      #select Kinetic Energy Correction Factor
      alpha1 = 0.0
      alpha2 = 0.0
      if nre[p] <= 2000.0
        alpha1 = 2.0
      elsif nre[p] > 2000.0 and nre[p] < 10.0 ** 7.0
        alpha1 = 1.0
      elsif nre[p] > 10.0 ** 7.0
        alpha1 = 0.85
      end

      if nre[p+1] <= 2000.0
        alpha2 = 2.0
      elsif nre[p+1] > 2000.0 and nre[p+1] < 10.0 ** 7.0
        alpha2 = 1.0
      elsif nre[p+1] > 10.0 ** 7.0
        alpha2 = 0.85
      end

      log.info("alpha1 = #{alpha1}")
      log.info("alpha2 = #{alpha2}")

      kinetic_correction1 = alpha1 / pipeID[p] ** 4.0
      kinetic_correction2 = alpha2 / pipeID[p+1] ** 4.0

      if !['Expansion','Contraction','Sudden Expansion','Sudden Contraction'].include?(fitting_type)
        kinetic_correction1 = 0.0
        kinetic_correction2 = 0.0
      end

      log.info("kinetic_correction1 = #{kinetic_correction1}")
      log.info("kinetic_correction2 = #{kinetic_correction2}")
      log.info("volume_rate = #{volume_rate}")
      log.info("kfd[p] = #{kfd[p]}")

      #Kinetic Energy + Frictional Loss
      sumof_ke_and_ef = (0.810569 * volume_rate ** 2.0) * (kfd[p] + kinetic_correction2 - kinetic_correction1)

      log.info("SumofKEandEf = #{sumof_ke_and_ef}")

      #Potential Energy
      if circuit_piping.elev.nil?
        elevation[p] = 0.0
      else
        elevation[p] = convert_to_base_unit(:elevation,circuit_piping.elev)
      end

      pe  = 4.1698 * 10.0 **  8.0 * elevation[p]  

      log.info("elevation[nn] = #{elevation[p]}")
      log.info("PE = #{pe}")

      pressure_drop[p] = density * ((sumof_ke_and_ef + pe) / (6.00444 * 10.0 ** 10.0)) 

      total_discharge_system_dp = total_discharge_system_dp + pressure_drop[p]

      log.info("pressure_drop[nn] = #{pressure_drop[p]}")
      log.info("total system discharge dp = #{total_discharge_system_dp}")

    end
  ########### end discharge side hydraulics  #########
  suction_nozzle_pressure = upstream_pressure - total_suction_system_dp
  discharge_nozzle_pressure = destination_pressure + total_discharge_system_dp
  pump_differential_pressure = discharge_nozzle_pressure - suction_nozzle_pressure
  pump_differential_head = pump_differential_pressure * (144 / density) 

  log.info("total system suction dp = #{total_suction_system_dp}")
  log.info("total system discharge dp = #{total_discharge_system_dp}")
  log.info("suction nozzle pressure = #{suction_nozzle_pressure}")
  log.info("discharge nozzle pressure = #{discharge_nozzle_pressure}")
  log.info("pump differential pressure = #{pump_differential_pressure}")
  log.info("pump differential head = #{pump_differential_head}")

  #save final values
  log.info("volume rate (capacity)  = #{final_volume_rate}")
  capacity = convert_to_project_unit(:cd_flow_rate, final_volume_rate) unless final_volume_rate == 0.0
  log.info("converted volume rate (capacity)  = #{capacity}")

  log.info("Pump Differential Head (system loss) = #{pump_differential_head}")
  pump_differential_head = convert_to_project_unit(:cd_differential_head, pump_differential_head)
  log.info("converted Pump Differential Head (system loss) = #{pump_differential_head}")
  end  #end for if i == 1 or 0 
  cp.update_attributes(:capacity => capacity, :system_loss => pump_differential_head)
end  ###### cps loop

end  #end of def pump_curve

end
