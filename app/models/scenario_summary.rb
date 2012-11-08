class ScenarioSummary < ActiveRecord::Base

  belongs_to :relief_device_sizing
  has_one    :scenario_identification
end
