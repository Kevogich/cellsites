class CreateProcures < ActiveRecord::Migration
  def self.up
    create_table :procures do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :procures
  end
end
