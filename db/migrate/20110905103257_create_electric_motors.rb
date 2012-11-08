class CreateElectricMotors < ActiveRecord::Migration
  def self.up
    create_table :electric_motors do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :driver_type
      t.string :electric_motor_tag
      
      t.string :equipment_type
      t.string :equipment_tag
      t.float :capacity, :limit => 53
      t.float :differential_pressure, :limit => 53
      t.float :horsepower, :limit => 53
      t.float :speed, :limit => 53
      
      t.string :motor_type
      t.string :enclosure
      t.float :hp, :limit => 53
      t.float :rpm, :limit => 53
      t.string :frame
      t.float :volt, :limit => 53
      t.string :phase
      t.string :cycle
      t.float :ambient_temperature, :limit => 53
      t.float :temperature_rise, :limit => 53
      t.string :bearing_type
      t.string :lubrication_type
      t.string :insulation_type
      t.string :time_rating
      t.string :mounting
      t.float :full_load_current, :limit => 53 
      t.float :service_factor, :limit => 53
      t.float :locked_rotor_current, :limit => 53
      
      #Heuristics Review
      t.string :ec_sizing_review_1
      t.string :ec_sizing_review_2
      t.string :ec_sizing_review_3
      t.string :ec_sizing_review_4
      t.string :ec_sizing_review_5
      t.string :ec_sizing_review_6
      t.string :ec_sizing_review_7
      t.string :ec_notes
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :electric_motors
  end
end
