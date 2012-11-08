class AddColumnToProject < ActiveRecord::Migration
  def self.up
	  add_column :projects, :storage_tank_vapor_space_capacity_above_maximum_level, :integer
  end

  def self.down
	  remove_column :projects, :storage_tank_vapor_space_capacity_above_maximum_level
  end
end
