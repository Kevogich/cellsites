class AddRddmToPressureReliefSystemDesignParameters < ActiveRecord::Migration
  def self.up
    add_column :pressure_relief_system_design_parameters, :rddm, :string, :limit => 50
  end

  def self.down
    remove_column :pressure_relief_system_design_parameters, :rddm
  end
end
