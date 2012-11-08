class AddColumnsToPumpSizing < ActiveRecord::Migration
  def self.up
  	rename_column :pump_sizings, :rd_type, :rd_stroke_action
  	add_column :pump_sizings, :rd_acc_head_factor_for_pump_type, :float, :limit => 53
  	add_column :pump_sizings, :rd_acc_head_factor_for_fluid_compressibility, :float, :limit => 53
  end

  def self.down
  	rename_column :pump_sizings, :rd_stroke_action, :rd_type
  	remove_column :pump_sizings, :rd_acc_head_factor_for_pump_type, :float, :limit => 53
  	remove_column :pump_sizings, :rd_acc_head_factor_for_fluid_compressibility, :float, :limit => 53
  end
end
