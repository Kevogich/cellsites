class AddPipeOdToLineSizing < ActiveRecord::Migration
  def self.up
  	add_column :line_sizings, :dc_spt_pipe_outer_diameter, :float, :limit => 53
  	add_column :line_sizings, :sc_selected_pipe_size, :float, :limit => 53
  end

  def self.down
  	remove_column :line_sizings, :dc_spt_pipe_outer_diameter
  	remove_column :line_sizings, :sc_selected_pipe_size, :float, :limit => 53
  end
end
