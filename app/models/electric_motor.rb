class ElectricMotor < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable

  validates_presence_of :electric_motor_tag, :project_id, :process_unit_id
  
  #convert values
  def convert_values(multiply_factor,project)
    #electric motor    
    self.capacity = (self.capacity.to_f * multiply_factor["Volumetric Flow Rate"]["Liquid"].to_f) if !multiply_factor["Volumetric Flow Rate"].nil?
    self.differential_pressure = (self.differential_pressure.to_f * multiply_factor["Pressure"]["Differential"].to_f) if !multiply_factor["Pressure"].nil?
    self.horsepower = (self.horsepower.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
    self.speed = (self.speed.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
    self.rpm = (self.rpm.to_f * multiply_factor["Revolution Speed"]["General"].to_f) if !multiply_factor["Revolution Speed"].nil?
    self.volt = (self.volt.to_f * multiply_factor["Electrical Potential"]["General"].to_f) if !multiply_factor["Electrical Potential"].nil?
    self.ambient_temperature = project.convert_temperature(:value => self.ambient_temperature, :subtype => "General")    
    self.temperature_rise = project.convert_temperature(:value => self.temperature_rise, :subtype => "General")
    self.full_load_current = (self.full_load_current.to_f * multiply_factor["Current"]["General"].to_f) if !multiply_factor["Current"].nil?
    self.service_factor = (self.service_factor.to_f * multiply_factor["Power"]["General"].to_f) if !multiply_factor["Power"].nil?
    self.locked_rotor_current = (self.locked_rotor_current.to_f * multiply_factor["Current"]["General"].to_f) if !multiply_factor["Current"].nil?
    save
  end
end
