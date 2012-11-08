class CreateCentrifugalPumps < ActiveRecord::Migration
  def self.up
    create_table :centrifugal_pumps do |t|
      
      t.integer :pump_sizing_id
      t.float :capacity, :limit => 53
      t.float :system_loss, :limit => 53
      t.float :head_1, :limit => 53
      t.float :head_2, :limit => 53
      t.float :head_3, :limit => 53
      t.float :head_4, :limit => 53

      t.timestamps
    end
  end

  def self.down
    drop_table :centrifugal_pumps
  end
end
