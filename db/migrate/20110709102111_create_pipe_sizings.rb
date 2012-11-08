class CreatePipeSizings < ActiveRecord::Migration
  def self.up
    create_table :pipe_sizings do |t|
      
      t.integer :line_sizing_id
      
      t.string :fitting_id
      t.string :fitting_tag
      t.float :pipe_size, :limit => 53
      t.string :pipe_schedule
      t.float :pipe_id, :limit => 53
      t.float :ds_cv, :limit => 53
      t.float :length, :limit => 53
      t.float :elev, :limit => 53
      t.float :p_outlet, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :pipe_sizings
  end
end
