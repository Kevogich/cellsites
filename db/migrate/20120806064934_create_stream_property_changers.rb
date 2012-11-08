class CreateStreamPropertyChangers < ActiveRecord::Migration
  def self.up
  	create_table :stream_property_changers do |t|
  		t.integer :stream_changable_id
  		t.string :stream_changable_type
  		t.integer :process_basis_id
  		t.string :stream_no
  		t.float :pressure, :limit => 53
  		t.float :temperature, :limit => 53
  		t.float :vapor_fraction, :limit => 53
  		t.float :vapor_density, :limit => 53
  		t.float :vapor_viscosity, :limit => 53
  		t.float :vapor_mw, :limit => 53
  		t.float :vapor_cp_cv, :limit => 53
  		t.float :liquid_density, :limit => 53
  		t.float :liquid_viscosity, :limit => 53
  		t.float :liquid_surface_tension, :limit => 53
  		t.timestamps
  	end
  end

  def self.down
    drop_table :stream_property_changers
  end
end
