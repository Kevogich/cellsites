class CreateScenarioSummaries < ActiveRecord::Migration
  def self.up
    create_table :scenario_summaries do |t|
      t.integer :relief_device_sizing_id
      t.string  :scenario
      t.string  :identifier
      t.string  :applicability, :limit => 50
      t.float   :relief_rate, :limit => 53
      t.float   :required_orifice, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :scenario_summaries
  end
end
