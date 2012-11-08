class CreateCompressorSizingTags < ActiveRecord::Migration
  def self.up
    create_table :compressor_sizing_tags do |t|
      t.integer :company_id
      t.integer :client_id
      t.integer :project_id
      t.integer :process_unit_id
      
      t.string :compressor_sizing_tag
      
      t.integer :created_by
      t.integer :updated_by
      
      t.timestamps
    end
  end

  def self.down
    drop_table :compressor_sizing_tags
  end
end
