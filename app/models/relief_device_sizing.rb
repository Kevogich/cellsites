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

  accepts_nested_attributes_for :relief_device_equipments, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_locations, :allow_destroy => true
  accepts_nested_attributes_for :relief_devices, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_rupture_disks, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_rupture_locations, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_open_vent_relief_devices, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_open_vent_locations, :allow_destroy => true
  accepts_nested_attributes_for :relief_device_low_pressure_vent_relief_devices, :allow_destroy => true
  accepts_nested_attributes_for :scenario_summaries,:reject_if => lambda { |ss| ss[:scenario].blank? }, :allow_destroy => true

  acts_as_commentable

  validates_presence_of :system_description
end
