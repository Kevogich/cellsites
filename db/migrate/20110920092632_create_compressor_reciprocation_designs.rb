class CreateCompressorReciprocationDesigns < ActiveRecord::Migration
  def self.up
    create_table :compressor_reciprocation_designs do |t|
      
      t.integer :compressor_sizing_id
      
      t.float :compression_ratio, :limit => 53
      t.float :no_of_cylinders, :limit => 53
      t.string :type
      t.float :bore, :limit => 53
      t.float :stroke, :limit => 53
      t.float :rod_diameter, :limit => 53
      t.float :piston_speed, :limit => 53
      t.float :clearance, :limit => 53
      t.float :suction_swept_volume, :limit => 53
      t.float :discharge_swept_volume, :limit => 53
      
      t.float :suction_stream, :limit => 53
      t.float :suction_pressure, :limit => 53
      t.float :suction_temperature, :limit => 53
      t.float :suction_vapor_mw, :limit => 53
      t.float :suction_vapor_z, :limit => 53
      t.float :suction_vapor_k, :limit => 53
      
      t.float :discharge_stream, :limit => 53
      t.float :discharge_pressure, :limit => 53
      t.float :discharge_temperature, :limit => 53
      t.float :discharge_vapor_z, :limit => 53
      t.float :discharge_vapor_k, :limit => 53
      
      t.float :interstage_piping, :limit => 53
      t.float :interstage_dp, :limit => 53
      t.float :suction_volume, :limit => 53
      t.float :discharge_volume, :limit => 53
      
      t.float :piston_displacement, :limit => 53
      t.float :volumetric_efficiency, :limit => 53
      t.float :capacity, :limit => 53
      t.float :efficiency, :limit => 53
      t.float :brake_horsepower, :limit => 53      
      
      t.timestamps
    end
  end

  def self.down
    drop_table :compressor_reciprocation_designs
  end
end
