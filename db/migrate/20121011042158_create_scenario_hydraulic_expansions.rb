class CreateScenarioHydraulicExpansions < ActiveRecord::Migration
  def self.up
    create_table :scenario_hydraulic_expansions do |t|

      t.integer :scenario_identification_id
      t.string :sr_1, :limit => 20
      t.string :sr_2, :limit => 20
      t.string :sr_3, :limit => 20
      t.string :sr_4, :limit => 20
      t.string :sr_5, :limit => 20
      t.string :sr_6, :limit => 20
      t.string :sr_7, :limit => 20
      t.string :applicability, :limit => 50
      t.string :determined_by, :limit => 50
      t.string :initial, :limit => 50
      t.datetime :date1
      t.text   :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :scenario_hydraulic_expansions
  end
end
