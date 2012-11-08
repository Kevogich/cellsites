class CreateCompressorCentrifugalDesigns < ActiveRecord::Migration
  def self.up
    create_table :compressor_centrifugal_designs do |t|
      
      t.integer :compressor_sizing_id
      
      t.float :compression_ratio, :limit => 53
      
      t.float :suction_stream, :limit => 53
      t.float :suction_pressure, :limit => 53
      t.float :suction_temperature, :limit => 53
      t.float :suction_mass_flow_rate, :limit => 53
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
      
      t.float :differential_pressure, :limit => 53
      t.float :differential_head, :limit => 53
      t.float :safety_factor, :limit => 53
      t.float :required_differential_head, :limit => 53
      t.float :max_head_stage, :limit => 53
      t.float :no_of_stages, :limit => 53
      t.float :head_per_impeller, :limit => 53
      t.float :efficiency, :limit => 53
      t.float :flow_rate, :limit => 53
      t.float :gas_hp, :limit => 53
      t.float :mechanical_losses, :limit => 53
      t.float :brake_horsepower, :limit => 53
      t.float :normal_speed, :limit => 53
      t.float :speed, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :compressor_centrifugal_designs
  end
end
