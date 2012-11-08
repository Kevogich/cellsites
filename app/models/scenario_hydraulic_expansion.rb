class ScenarioHydraulicExpansion < ActiveRecord::Base

  belongs_to :scenario_identification

  def display_date1
    self.date1.strftime("%m/%d/%Y")
  end
end
