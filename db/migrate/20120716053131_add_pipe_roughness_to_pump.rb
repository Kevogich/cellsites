class AddPipeRoughnessToPump < ActiveRecord::Migration
  def self.up
  	add_column :pump_sizings, :su_pipe_id, :integer
  	add_column :pump_sizings, :su_pipe_roughness, :float, :limit => 53
  end

  def self.down
  	remove_column :pump_sizings, :su_pipe_id
  	remove_column :pump_sizings, :su_pipe_roughness
  end
end
