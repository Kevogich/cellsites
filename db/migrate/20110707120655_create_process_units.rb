class CreateProcessUnits < ActiveRecord::Migration
  def self.up
    create_table :process_units do |t|
         
      t.integer :project_id
      t.string :name
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :process_units
  end
end
