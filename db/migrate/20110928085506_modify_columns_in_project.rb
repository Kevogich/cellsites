class ModifyColumnsInProject < ActiveRecord::Migration
  def self.up
    change_column :projects, :barometric_pressure, :float, :limit => 53
    change_column :projects, :default_pressure_drop_ratio_factor, :float, :limit => 53
    change_column :projects, :control_flow_bias_min, :float, :limit => 53
    change_column :projects, :control_flow_bias_normal, :float, :limit => 53
    change_column :projects, :control_flow_bias_max, :float, :limit => 53
    change_column :projects, :default_pressure_drop_ratio_factor, :float, :limit => 53
    change_column :projects, :allowable_centrifugal_compressor_mawt, :float, :limit => 53
    change_column :projects, :compressor_design_safety_factor, :float, :limit => 53    
  end

  def self.down
    change_column :projects, :barometric_pressure, :string
    change_column :projects, :default_pressure_drop_ratio_factor, :string
    change_column :projects, :control_flow_bias_min, :string
    change_column :projects, :control_flow_bias_normal, :string
    change_column :projects, :control_flow_bias_max, :string
    change_column :projects, :default_pressure_drop_ratio_factor, :string
    change_column :projects, :allowable_centrifugal_compressor_mawt, :string
    change_column :projects, :compressor_design_safety_factor, :string
  end
end
