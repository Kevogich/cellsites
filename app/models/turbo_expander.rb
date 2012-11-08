class TurboExpander < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable

  validates_presence_of :turbo_expander_tag, :project_id, :process_unit_id 
                         
  #validate :stream_inlet_check_box
  
  #validations code
  def stream_inlet_check_box
    #raise sic_mininum.to_yaml
    if sic_mininum == false && sic_normal == false && sic_maximum == false
       errors[:base] << "Select any one check box minimum, normal, maximum"
    end
  end

  #convert values
  def convert_values(multiply_factor,project)
  # Stream inlet conditions
    self.sic_min_stream_inlet_pressure= (self.sic_min_stream_inlet_pressure.to_f * multiply_factor["Pressure"]["General"]) if !multiply_factor["Pressure"].nil?
    self.sic_nor_stream_inlet_pressure= (self.sic_nor_stream_inlet_pressure.to_f * multiply_factor["Pressure"]["General"]) if !multiply_factor["Pressure"].nil?
    self.sic_max_stream_inlet_pressure= (self.sic_max_stream_inlet_pressure.to_f * multiply_factor["Pressure"]["General"]) if !multiply_factor["Pressure"].nil?
    self.sic_min_stream_inlet_temperature= project.convert_temperature(:value => self.sic_min_stream_inlet_temperature, :subtype => "General")
    self.sic_nor_stream_inlet_temperature= project.convert_temperature(:value => self.sic_nor_stream_inlet_temperature, :subtype => "General")
    self.sic_max_stream_inlet_temperature= project.convert_temperature(:value => self.sic_max_stream_inlet_temperature, :subtype => "General")
    self.sic_min_stream_saturation_temperature=project.convert_temperature(:value => self.sic_min_stream_saturation_temperature, :subtype => "General")
    self.sic_nor_stream_saturation_temperature=project.convert_temperature(:value => self.sic_nor_stream_saturation_temperature, :subtype => "General")
    self.sic_max_stream_saturation_temperature=project.convert_temperature(:value => self.sic_max_stream_saturation_temperature, :subtype => "General")
    self.sic_min_stream_flowrate=(self.sic_min_stream_flowrate.to_f * multiply_factor["Mass Flow Rate"]["General"]) if !multiply_factor["Mass Flow Rate"].nil?
    self.sic_nor_stream_flowrate=(self.sic_nor_stream_flowrate.to_f * multiply_factor["Mass Flow Rate"]["General"]) if !multiply_factor["Mass Flow Rate"].nil?
    self.sic_max_stream_flowrate=(self.sic_max_stream_flowrate.to_f * multiply_factor["Mass Flow Rate"]["General"]) if !multiply_factor["Mass Flow Rate"].nil?
    self.sic_min_stream_density=(self.sic_min_stream_density.to_f * multiply_factor["Density"]["General"]) if !multiply_factor["Density"].nil?
    self.sic_nor_stream_density=(self.sic_nor_stream_density.to_f * multiply_factor["Density"]["General"]) if !multiply_factor["Density"].nil?
    self.sic_max_stream_density=(self.sic_max_stream_density.to_f * multiply_factor["Density"]["General"]) if !multiply_factor["Density"].nil?
    self.sic_min_stream_entropy=(self.sic_min_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.sic_nor_stream_entropy=(self.sic_nor_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.sic_max_stream_entropy=(self.sic_max_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.sic_min_stream_enthalpy=(self.sic_min_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.sic_nor_stream_enthalpy=(self.sic_nor_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.sic_max_stream_enthalpy=(self.sic_max_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?

    #stream outlet conditions
    self.soc_min_outlet_pressure= (self.soc_min_outlet_pressure.to_f * multiply_factor["Pressure"]["General"]) if !multiply_factor["Pressure"].nil?
    self.soc_nor_outlet_pressure= (self.soc_nor_outlet_pressure.to_f * multiply_factor["Pressure"]["General"]) if !multiply_factor["Pressure"].nil?
    self.soc_max_outlet_pressure= (self.soc_max_outlet_pressure.to_f * multiply_factor["Pressure"]["General"]) if !multiply_factor["Pressure"].nil?
    self.soc_min_outlet_temperature= project.convert_temperature(:value => self.soc_min_outlet_temperature, :subtype => "General")
    self.soc_nor_outlet_temperature= project.convert_temperature(:value => self.soc_nor_outlet_temperature, :subtype => "General")
    self.soc_max_outlet_temperature= project.convert_temperature(:value => self.soc_max_outlet_temperature, :subtype => "General")
    self.soc_min_stream_saturation_temperature= project.convert_temperature(:value => self.soc_min_stream_saturation_temperature, :subtype => "General")
    self.soc_nor_stream_saturation_temperature= project.convert_temperature(:value => self.soc_nor_stream_saturation_temperature, :subtype => "General")
    self.soc_max_stream_saturation_temperature= project.convert_temperature(:value => self.soc_max_stream_saturation_temperature, :subtype => "General")

    self.soc_min_stream_density= (self.soc_min_stream_density.to_f * multiply_factor["Density"]["General"]) if !multiply_factor["Density"].nil?
    self.soc_nor_stream_density= (self.soc_nor_stream_density.to_f * multiply_factor["Density"]["General"]) if !multiply_factor["Density"].nil?
    self.soc_max_stream_density= (self.soc_max_stream_density.to_f * multiply_factor["Density"]["General"]) if !multiply_factor["Density"].nil?

    self.soc_min_stream_entropy=(self.soc_min_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.soc_nor_stream_entropy=(self.soc_nor_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.soc_max_stream_entropy=(self.soc_max_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?

    self.soc_min_stream_enthalpy=(self.soc_min_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.soc_nor_stream_enthalpy=(self.soc_nor_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.soc_max_stream_enthalpy=(self.soc_max_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?

    self.soc_min_stream_vapor_entropy=(self.soc_min_stream_vapor_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.soc_min_stream_vapor_entropy=(self.soc_min_stream_vapor_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.soc_min_stream_vapor_entropy=(self.soc_min_stream_vapor_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?

    self.soc_min_stream_vapor_enthalpy=(self.soc_min_stream_vapor_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.soc_nor_stream_vapor_enthalpy=(self.soc_nor_stream_vapor_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.soc_max_stream_vapor_enthalpy=(self.soc_max_stream_vapor_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?

    self.soc_min_stream_liquid_entropy=(self.soc_min_stream_liquid_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.soc_min_stream_liquid_entropy=(self.soc_min_stream_liquid_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.soc_min_stream_liquid_entropy=(self.soc_min_stream_liquid_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?

    self.soc_min_stream_liquid_enthalpy=(self.soc_min_stream_liquid_entropy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.soc_nor_stream_liquid_enthalpy=(self.soc_min_stream_liquid_entropy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.soc_max_stream_liquid_enthalpy=(self.soc_min_stream_liquid_entropy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?

    #Expander Design
    self.ed_theoretical_enthalpy_change= (self.ed_theoretical_enthalpy_change.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.ed_actual_enthalpy_change= (self.ed_actual_enthalpy_change.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.ed_capacity= (self.ed_capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"]) if !multiply_factor["Volumetric Flow Rate"].nil?
    self.ed_differential_pressure= (self.ed_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.ed_actual_outlet_temperature= project.convert_temperature(:value => self.ed_actual_outlet_temperature, :subtype => "General")
    #raise multiply_factor["Power"].to_yaml
    self.ed_horsepower= (self.ed_horsepower.to_f * multiply_factor["Power"]["General"]) if !multiply_factor["Power"].nil?
    self.ed_actual_outlet_stream_entropy=(self.ed_actual_outlet_stream_entropy.to_f * multiply_factor["Entropy"]["General"]) if !multiply_factor["Entropy"].nil?
    self.ed_actual_outlet_stream_enthalpy=(self.ed_actual_outlet_stream_enthalpy.to_f * multiply_factor["Enthalpy"]["General"]) if !multiply_factor["Enthalpy"].nil?
    self.ed_basis_flow_rate=(self.ed_basis_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"]) if !multiply_factor["Mass Flow Rate"].nil?
    self.ed_work_produced=(self.ed_work_produced.to_f * multiply_factor["Power"]["General"]) if !multiply_factor["Power"].nil?
    self.ed_horsepower_produced=(self.ed_horsepower_produced.to_f * multiply_factor["Power"]["General"]) if !multiply_factor["Power"].nil?
    self.ed_net_horsepower=(self.ed_net_horsepower.to_f *  multiply_factor["Power"]["General"]) if !multiply_factor["Power"].nil?

    save
  end
end
