class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      
      t.integer :heat_and_material_property_id
      t.string :stream_no
      t.string :stream_value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end
