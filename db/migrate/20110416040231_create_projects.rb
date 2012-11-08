class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :company_id
      t.integer :client_id
      t.string :location
      t.string :project_num
      t.string :document_num
      t.integer :units_of_measurement_id

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
