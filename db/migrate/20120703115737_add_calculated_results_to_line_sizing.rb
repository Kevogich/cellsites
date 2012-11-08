class AddCalculatedResultsToLineSizing < ActiveRecord::Migration
  def self.up
	  add_column :line_sizings, :calculated_results, :text
  end

  def self.down
	  remove_column :line_sizings, :calculated_results
  end
end
