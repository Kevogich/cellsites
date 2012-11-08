class CreateUserProjectSettings < ActiveRecord::Migration
  def self.up
    create_table :user_project_settings do |t|
      
      t.integer :user_id
      
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_project_settings
  end
end
