class RemoveSizingCriteriasFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :sizing_criterias
  end

  def self.down
    add_column :projects, :sizing_criterias, :text
  end
end
