class CreateTitles < ActiveRecord::Migration
  def self.up
    create_table :titles do |t|
      t.references :company
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :titles
  end
end
