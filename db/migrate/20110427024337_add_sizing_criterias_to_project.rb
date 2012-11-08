class AddSizingCriteriasToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :sizing_criterias, :text
  end

  def self.down
    remove_column :projects, :sizing_criterias
  end
end
