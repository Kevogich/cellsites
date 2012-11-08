class CreatePipings < ActiveRecord::Migration
  def self.up
    create_table :pipings do |t|
      t.integer :pipeable_id
      t.string  :pipeable_type
      t.string  :sub_type

      t.integer :sequence_no

      t.string  :fitting
      t.string  :fitting_tag
      t.string  :pipe_size
      t.string  :pipe_schedule
      t.float :pipe_id, :limit => 53
      t.float :per_flow, :limit => 53
      t.float :ds_cv, :limit => 53
      t.float :length, :limit => 53
      t.float :elevation, :limit => 53
      t.float :delta_p, :limit => 53
      t.float :outlet_pressure, :limit => 53
      t.float :inlet_pressure, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :pipings
  end
end
