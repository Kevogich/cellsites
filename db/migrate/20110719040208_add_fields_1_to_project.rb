class AddFields1ToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :vertical_seperator, :float, :limit => 53
    add_column :projects, :max_liquid_level, :float, :limit => 53
  end

  def self.down
    remove_column :projects, :vertical_seperator
    remove_column :projects, :max_liquid_level
  end
end
