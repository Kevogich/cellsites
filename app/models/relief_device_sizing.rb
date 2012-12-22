class ReliefDeviceSizing < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :relief_device_equipments, :dependent => :destroy
  has_many :relief_devices, :dependent => :destroy
  has_many :relief_device_locations, :dependent => :destroy
  has_many :relief_device_rupture_disks, :dependent => :destroy
  has_many :relief_device_rupture_locations, :dependent => :destroy
  has_many :relief_device_open_vent_relief_devices, :dependent => :destroy
  has_many :relief_device_open_vent_locations, :dependent => :destroy
  has_many :relief_device_low_pressure_vent_relief_devices, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy
  has_many :scenario_summaries, :dependent => :destroy
  has_many :scenario_identifications, :through => :scenario_summaries
  has_many :relief_device_system_descriptions, :dependent => :destroy

  accepts_nested_attributes_for :relief_device_equipments, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_locations, :allow_destroy => true
  accepts_nested_attributes_for :relief_devices, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_rupture_disks, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_rupture_locations, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_open_vent_relief_devices, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_open_vent_locations, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_low_pressure_vent_relief_devices, :allow_destroy => true
  accepts_nested_attributes_for :scenario_summaries, :reject_if => lambda { |ss| ss[:identifier].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_system_descriptions,:reject_if => lambda { |sd| sd[:equipment_type].blank? }, :allow_destroy => true

  acts_as_commentable

  validates_presence_of :system_description



  def uom_mapping
    {
      :su_pressure                       => ["Pressure", "General"],
      :su_temperature                    => ["Temperature", "General"],
      :orifice_area                      => ["Area", "Orifice"],
      :lowest_set_pressure               => ["Pressure", "General"],
      :su_mass_flow_rate                 => ["Mass Flow Rate", "General"],
      "Head"                             => ["Length", "Large Dimension Length"]
    }
  end

  def convert_to_base_unit(att,value=nil)
#   value = self.send(att) if value.nil?
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



end
