class ScenarioIdentification < ActiveRecord::Base

  belongs_to :scenario_summary
  has_one :scenario_hydraulic_expansion, :dependent => :destroy
  has_one :relief_rate_generic, :dependent => :destroy

  has_many :pipings, :as => :pipeable, :dependent => :destroy

  has_many :attachments, :as => :attachable, :dependent => :destroy
  acts_as_commentable

  accepts_nested_attributes_for :pipings, :reject_if => lambda { |p| p[:fitting].blank? }, :allow_destroy => true


  def self.relief_capacity_calculation_method_list(relief_device_type)
    list =
      {"Pressure Relief Valve" =>
         ["Vapor - Critical",
          "Vapor - Subcritical",
          "Vapor - Steam",
          "Liquid - Certified",
          "Liquid - Non Certified",
          "Two Phase HEM",
          "Generic"],
       "Rupture Disk" => [
         "Vapor - Critical",
         "Vapor - Subcritical",
         "Vapor - Steam",
         "Liquid - Certified",
         "Liquid - Non Certified",
         "Two Phase HEM",
         "Generic",
         "Line Capacity"],
       "Open Vent" => [
         "Generic",
         "Line Capacity"],
       "Low Pressure Vent" => [
         "Low Pressure Vent",
         "Generic",
         "Line Capacity"],
       "" => []
      }

    list[relief_device_type]
  end
end
