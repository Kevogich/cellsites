class CreateCompressorSizingModes < ActiveRecord::Migration
  def self.up
    create_table :compressor_sizing_modes do |t|
      
      t.integer :compressor_sizing_tag_id
      t.string :mode_name

      t.timestamps
    end
  end

  def self.down
    drop_table :compressor_sizing_modes
  end
end
