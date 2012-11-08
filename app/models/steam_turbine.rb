class SteamTurbine < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable
  
  validates_presence_of :steam_turbine_tag, :project_id, :process_unit_id                        
                        
  #validates :std_ee_turbine_type, :presence => { :message => "Turbine Type is required" }
  def convert_values(multiply_factor,project)
    #Steam Supply Conditions
    self.ssc_min_steam_supply_pressure = (self.ssc_min_steam_supply_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.ssc_min_steam_supply_temperature = project.convert_temperature(:value => self.ssc_min_steam_supply_temperature, :subtype => "General")
    self.ssc_min_steam_saturation_temperature = project.convert_temperature(:value => self.ssc_min_steam_saturation_temperature, :subtype => "General")
    self.ssc_min_steam_density = (self.ssc_min_steam_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.ssc_min_steam_entropy = (self.ssc_min_steam_entropy.to_f * multiply_factor["Entropy"]["General"].to_f) if !multiply_factor["Entropy"].nil?
    self.ssc_min_steam_enthalpy = (self.ssc_min_steam_enthalpy.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.ssc_nor_steam_supply_pressure = (self.ssc_nor_steam_supply_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.ssc_nor_steam_supply_temperature = project.convert_temperature(:value => self.ssc_nor_steam_supply_temperature, :subtype => "General")
    self.ssc_nor_steam_saturation_temperature = project.convert_temperature(:value => self.ssc_nor_steam_saturation_temperature, :subtype => "General")
    self.ssc_nor_steam_density = (self.ssc_nor_steam_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.ssc_nor_steam_entropy = (self.ssc_nor_steam_entropy.to_f * multiply_factor["Entropy"]["General"].to_f) if !multiply_factor["Entropy"].nil?
    self.ssc_nor_steam_enthalpy = (self.ssc_nor_steam_enthalpy.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.ssc_max_steam_supply_pressure = (self.ssc_max_steam_supply_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.ssc_max_steam_supply_temperature = project.convert_temperature(:value => self.ssc_max_steam_supply_temperature, :subtype => "General")
    self.ssc_max_steam_saturation_temperature = project.convert_temperature(:value => self.ssc_max_steam_saturation_temperature, :subtype => "General")
    self.ssc_max_steam_density = (self.ssc_max_steam_density.to_f * multiply_factor["Density"]["General"].to_f) if !multiply_factor["Density"].nil?
    self.ssc_max_steam_entropy = (self.ssc_max_steam_entropy.to_f * multiply_factor["Entropy"]["General"].to_f) if !multiply_factor["Entropy"].nil?
    self.ssc_max_steam_enthalpy = (self.ssc_max_steam_enthalpy.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
    
    #Steam Exhaust Conditions
    self.sec_min_steam_exhaust_pressure = (self.sec_min_steam_exhaust_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.sec_min_steam_exhaust_temperature = project.convert_temperature(:value => self.sec_min_steam_exhaust_temperature, :subtype => "General")
    self.sec_min_steam_saturation_temperature = project.convert_temperature(:value => self.sec_min_steam_saturation_temperature, :subtype => "General")
    self.sec_min_steam_density = (self.sec_min_steam_density.to_f * multiply_factor["Density"]["Differential"].to_f) if !multiply_factor["Density"].nil?
    #self.sec_min_steam_entropy = (self.sec_min_steam_entropy.to_f * multiply_factor["Entropy"]["Differential"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_min_steam_enthalpy = (self.sec_min_steam_enthalpy.to_f * multiply_factor["Enthalpy"]["Differential"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_min_water_entropy = (self.sec_min_water_entropy.to_f * multiply_factor["Entropy"]["Differential"].to_f) if !multiply_factor["Entropy"].nil?
    self.sec_min_water_enthalpy = (self.sec_min_water_enthalpy.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_nor_steam_exhaust_pressure = (self.sec_nor_steam_exhaust_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.sec_nor_steam_exhaust_temperature = project.convert_temperature(:value => self.sec_nor_steam_exhaust_temperature, :subtype => "General")
    self.sec_nor_steam_saturation_temperature = project.convert_temperature(:value => self.sec_nor_steam_saturation_temperature, :subtype => "General")
    self.sec_nor_steam_density = (self.sec_nor_steam_density.to_f * multiply_factor["Density"]["Differential"].to_f) if !multiply_factor["Density"].nil?
    self.sec_nor_steam_entropy = (self.sec_nor_steam_entropy.to_f * multiply_factor["Entropy"]["Differential"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_nor_steam_enthalpy = (self.sec_nor_steam_enthalpy.to_f * multiply_factor["Enthalpy"]["Differential"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_nor_water_entropy = (self.sec_nor_water_entropy.to_f *  multiply_factor["Entropy"]["Differential"].to_f) if !multiply_factor["Entropy"].nil?
    self.sec_nor_water_enthalpy = (self.sec_nor_water_enthalpy.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_max_steam_exhaust_pressure = (self.sec_max_steam_exhaust_pressure.to_f * multiply_factor["Pressure"]["General"].to_f) if !multiply_factor["Pressure"].nil?
    self.sec_max_steam_exhaust_temperature = project.convert_temperature(:value => self.sec_max_steam_exhaust_temperature, :subtype => "General")
    self.sec_max_steam_saturation_temperature = project.convert_temperature(:value => self.sec_max_steam_saturation_temperature, :subtype => "General")
    self.sec_max_steam_density = (self.sec_max_steam_density.to_f * multiply_factor["Density"]["Differential"].to_f) if !multiply_factor["Density"].nil?
    self.sec_max_steam_entropy = (self.sec_max_steam_entropy.to_f * multiply_factor["Entropy"]["Differential"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_max_steam_enthalpy = (self.sec_max_steam_enthalpy.to_f * multiply_factor["Enthalpy"]["Differential"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.sec_max_water_entropy = (self.sec_max_water_entropy.to_f * multiply_factor["Entropy"]["Differential"].to_f) if !multiply_factor["Entropy"].nil?
    self.sec_max_water_enthalpy = (self.sec_max_water_enthalpy.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
       
    #Steam Turbine Design    
    self.std_capacity = (self.std_capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
    self.std_differential_pressure = (self.std_differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.std_horsepower = (self.std_horsepower.to_f * multiply_factor["Horsepower"]["General"].to_f) if !multiply_factor["Horsepower"].nil?
    self.std_speed = (self.std_speed.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
    self.std_inlet_nozzle_diameter = (self.std_inlet_nozzle_diameter.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.std_exhaust_nozzle_diameter = (self.std_exhaust_nozzle_diameter.to_f * multiply_factor["Length"]["Small Dimension Length"].to_f) if !multiply_factor["Length"].nil?
    self.std_max_velocity_at_inlet_nozzle = (self.std_max_velocity_at_inlet_nozzle.to_f * multiply_factor["Velocity"]["General"].to_f) if !multiply_factor["Velocity"].nil?
    self.std_max_velocity_at_exhaust_nozzle = (self.std_max_velocity_at_exhaust_nozzle.to_f * multiply_factor["Velocity"]["General"].to_f) if !multiply_factor["Velocity"].nil?
    self.std_isentropic_enthalpy_change = (self.std_isentropic_enthalpy_change.to_f * multiply_factor["Enthalpy"]["General"].to_f) if !multiply_factor["Enthalpy"].nil?
    self.std_theoretical_steam_rate = (self.std_theoretical_steam_rate.to_f * multiply_factor["Steam Rate"]["General"].to_f) if !multiply_factor["Steam Rate"].nil?
    self.std_actual_steam_rate = (self.std_actual_steam_rate.to_f * multiply_factor["Steam Rate"]["General"].to_f) if !multiply_factor["Steam Rate"].nil?
    self.std_steam_flow_rate = (self.std_steam_flow_rate.to_f * multiply_factor["Mass Flow Rate"]["General"].to_f) if !multiply_factor["Mass Flow Rate"].nil?
    self.std_ee_degree_of_superheat = project.convert_temperature(:value => self.std_ee_degree_of_superheat, :subtype => "General")
     
    save    
  end
  
  #static data from steam turbine.xls
  def self.non_condensing_turbine
    data_array = [
                  [0,     100,  200,  400,  600,  1200, 1800, 0],
                  [300,   61.5, 58.5, 52.5, 0,    0,    0,    0],
                  [325,   0,    0,    0,    50,   0,    0,    0],
                  [500,   64.8, 62,   57.4, 54,   0,    0,    0],
                  [600,   0,    0,    0,    0,    50.5, 0,    0],
                  [1000,  69,   67,   63.5, 60.5, 55,   0,    0],
                  [1500,  0,    0,    0,    0,    0,    50.5, 0],
                  [2000,  73,   71.5, 69,   65,   61.5, 53.5, 0],
                  [3000,  74.5, 73.5, 71.5, 69,   65,   58.5, 0],
                  [4000,  76,   75,   73,   71.2, 67.4, 61.5, 0],
                  [5000,  76.8, 75.5, 74,   72.5, 69,   64,   0],
                  [6000,  77,   76.5, 74.8, 73.5, 70.4, 66,   0],
                  [7000,  77.5, 76.8, 75.5, 74.5, 71.5, 67.5, 0],
                  [8000,  78,   77,   76.2, 75,   72,   68.5, 0],
                  [9000,  78.2, 77.5, 76.6, 75.5, 73,   69.5, 0],
                  [10000, 78.4, 77.8, 77,   76,   73.5, 70.5, 0],
                  [0,     0,    0,    0,    0,    0,    0,    0]
                 ]
    return data_array                
  end
  
  def self.condensing_turbine
    data_array = [
                  [0,     100,  200,  400,  600,  1200, 1800, 0],
                  [300,   60.0, 58.0, 55.0, 52.5, 0,    0,    0],
                  [325,   0,    0,    0,    0,    50.0, 0,    0],
                  [500,   63.5, 61.5, 58.5, 56.5, 53.5, 50.0, 0],
                  [1000,  67.6, 66.0, 63.5, 61.5, 58.8, 55.5, 0],
                  [2000,  71.8, 70.0, 68.0, 66.5, 63.5, 61.0, 0],
                  [3000,  73.5, 72.5, 70.5, 69.0, 66.5, 64.5, 0],
                  [4000,  75.0, 73.5, 72.0, 70.5, 68.0, 66.2, 0],
                  [5000,  75.8, 74.5, 73.0, 72.0, 69.5, 68.0, 0],
                  [6000,  76.4, 75.5, 73.8, 73.0, 70.5, 69.0, 0],
                  [7000,  76.8, 76.0, 74.5, 73.5, 71.5, 69.8, 0],
                  [8000,  77.0, 76.5, 75.0, 74.0, 72.0, 70.5, 0],
                  [9000,  77.5, 76.8, 75.5, 74.5, 73.0, 71.3, 0],
                  [10000, 77.8, 77.0, 76.0, 75.0, 73.4, 72.0, 0],
                  [15000, 78.4, 78.0, 77.0, 76.4, 75.0, 74.0, 0]
                 ]
    return data_array             
  end
  
  def self.rated_horsepower
    data_array = [
                  [0,     1000,  2000,  3000,  5000,  10000, 12500, 15000, 0],
                  [3650,  1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 0],
                  [4000,  1.003, 1.002, 1.000, 0.998, 0.996, 0.996, 0.994, 0],
                  [4500,  1.006, 1.003, 0.999, 0.995, 0.990, 0.989, 0.986, 0],
                  [5000,  1.008, 1.002, 0.996, 0.990, 0.983, 0.980, 0.976, 0],
                  [5500,  1.009, 1.000, 0.992, 0.984, 0.976, 0.973, 0.967, 0],
                  [6000,  1.009, 0.998, 0.986, 0.977, 0.967, 0.962, 0.955, 0],
                  [6500,  1.008, 0.993, 0.980, 0.968, 0.958, 0.951, 0.941, 0],
                  [7000,  1.005, 0.988, 0.972, 0.960, 0.948, 0.940, 0.928, 0],
                  [7500,  1.002, 0.982, 0.965, 0.950, 0.937, 0.928, 0.913, 0],
                  [8000,  0.997, 0.975, 0.957, 0.940, 0.926, 0.916, 0.900, 0],
                  [8500,  0.991, 0.967, 0.946, 0.928, 0.915, 0.902, 0.882, 0],
                  [8800,  0.985, 0.960, 0.937, 0.920, 0.905, 0.893, 0.870, 0],
                  [9000,  0.983, 0.956, 0.935, 0.916, 0.902, 0.889, 0,     0],
                  [9500,  0.975, 0.945, 0.920, 0.903, 0.890, 0.874, 0,     0],
                  [9700,  0.973, 0.943, 0.920, 0.900, 0.888, 0.870, 0,     0],
                  [10000, 0.966, 0.934, 0.912, 0.892, 0.878, 0,     0,     0]
                 ]
    return data_array
  end
  
  def self.speed
    data_array = [
                  [0,    1000,  1400, 1800, 2400, 3000, 5000, 7000, 10000, 0],
                  [0,    84,    0,    0,    0,    0,    0,    0,    0,     0],
                  [0.05, 95,    70,   55,   44,   36,   26,   23,   21.5,  0],
                  [0.1,  107.5, 78,   62,   50,   40,   32.5, 28,   26,    0],
                  [0.15, 120,   88,   70,   56,   47,   38,   34,   30,    0],
                  [0.2,  127,   96,   78,   63,   53,   45,   40,   36,    0],
                  [0.25, 135,   110,  84,   70,   59,   50,   45,   42,    0],
                  [0.3,  150,   120,  94,   76,   65,   56,   50,   50,    0],
                  [0.35, 160,   125,  100,  82,   71,   64,   55,   55,    0],
                  [0.4,  170,   130,  110,  90,   78,   70,   60,   60,    0],
                  [0.45, 187.5, 140,  122,  100,  90,   76,   70,   70,    0],
                  [0.5,  200,   160,  132,  120,  102,  87,   80,   80,    0],
                  [0.55, 212,   180,  150,  130,  120,  98,   92,   92,    0]
                 ]
    return data_array
  end
    
end
