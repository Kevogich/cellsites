class Addmeasuresubtypetomeasureunit < ActiveRecord::Migration
  def self.up
    add_column :measure_units, :measurement_sub_type_id, :integer
    add_column :measure_units, :conversion_factor, :integer
  end

  def self.down
    remove_column :measure_units, :measurement_sub_type_id
    remove_column :measure_units, :conversion_factor
  end
end
