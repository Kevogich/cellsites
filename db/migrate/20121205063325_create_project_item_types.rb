class CreateProjectItemTypes < ActiveRecord::Migration
  def self.up
    create_table :project_item_types do |t|
      t.integer :item_type_id
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_item_types
  end
end
