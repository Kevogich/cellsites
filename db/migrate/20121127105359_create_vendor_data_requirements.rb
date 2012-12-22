class CreateVendorDataRequirements < ActiveRecord::Migration
  def self.up
    create_table :vendor_data_requirements do |t|
      t.string :vendor_data_requirement

      t.timestamps
    end
  end

  def self.down
    drop_table :vendor_data_requirements
  end
end
