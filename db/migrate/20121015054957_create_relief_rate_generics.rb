class CreateReliefRateGenerics < ActiveRecord::Migration
  def self.up
    create_table :relief_rate_generics do |t|
      t.integer :scenario_identification_id
      t.float   :relief_rate, :limit => 53
      t.float   :relief_pressure, :limit => 53
      t.text    :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :relief_rate_generics
  end
end
