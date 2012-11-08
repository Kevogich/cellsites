class CreateProjectPipes < ActiveRecord::Migration
  def self.up
    create_table :project_pipes do |t|
      t.integer :project_id
      t.integer :pipe_id
      t.float :roughness

      t.timestamps
    end
  end

  def self.down
    drop_table :project_pipes
  end
end
