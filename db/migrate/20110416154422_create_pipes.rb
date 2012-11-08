class CreatePipes < ActiveRecord::Migration
  def self.up
    create_table :pipes do |t|
      t.string :material
      t.string :conditions
      t.float :roughness_min
      t.float :roughness_max
      t.float :roughness_recommended

      t.timestamps
    end
  end

  def self.down
    drop_table :pipes
  end
end
