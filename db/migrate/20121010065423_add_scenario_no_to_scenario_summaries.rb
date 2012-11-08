class AddScenarioNoToScenarioSummaries < ActiveRecord::Migration
  def self.up
    add_column :scenario_summaries, :scenario_no, :integer
  end

  def self.down
    remove_column :scenario_summaries, :scenario_no
  end
end
