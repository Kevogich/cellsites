class ChangeSizingCriteriaColumns < ActiveRecord::Migration
  def self.up
    change_column :sizing_criterias, :velocity_min, :float
    change_column :sizing_criterias, :velocity_max, :float
    change_column :sizing_criterias, :velocity_sel, :float
    change_column :sizing_criterias, :delta_per_100ft_min, :float
    change_column :sizing_criterias, :delta_per_100ft_max, :float
    change_column :sizing_criterias, :delta_per_100ft_sel, :float
	
	change_column :project_sizing_criterias, :velocity_min, :float
	change_column :project_sizing_criterias, :velocity_max, :float
	change_column :project_sizing_criterias, :velocity_sel, :float

    change_column :project_sizing_criterias, :delta_per_100ft_min, :float
    change_column :project_sizing_criterias, :delta_per_100ft_max, :float
    change_column :project_sizing_criterias, :delta_per_100ft_sel, :float

  end


  def self.down
    change_column :sizing_criterias, :velocity_min, :integer
    change_column :sizing_criterias, :velocity_max, :integer
    change_column :sizing_criterias, :velocity_sel, :integer
    change_column :sizing_criterias, :delta_per_100ft_min, :integer
    change_column :sizing_criterias, :delta_per_100ft_max, :integer
    change_column :sizing_criterias, :delta_per_100ft_sel, :integer

	change_column :project_sizing_criterias, :velocity_min, :integer
	change_column :project_sizing_criterias, :velocity_max, :integer
	change_column :project_sizing_criterias, :velocity_sel, :integer

    change_column :project_sizing_criterias, :delta_per_100ft_min, :integer
    change_column :project_sizing_criterias, :delta_per_100ft_max, :integer
    change_column :project_sizing_criterias, :delta_per_100ft_sel, :integer
	
  end
end
