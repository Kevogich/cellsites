class AddCvAndFeSummaryToPumpSizing < ActiveRecord::Migration
  def self.up
  	add_column :pump_sizings, :fe_summary, :text
  	add_column :pump_sizings, :cv_summary, :text
  end

  def self.down
  	remove_column :pump_sizings, :fe_summary
  	remove_column :pump_sizings, :cv_summary
  end
end
