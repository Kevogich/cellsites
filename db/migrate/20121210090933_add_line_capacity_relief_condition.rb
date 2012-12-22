class AddLineCapacityReliefCondition < ActiveRecord::Migration
  def self.up
    add_column :scenario_identifications, :line_capacity_relief_condition, :string
  end

  def self.down
    remove_column :scenario_identifications, :line_capacity_relief_condition
  end
end
