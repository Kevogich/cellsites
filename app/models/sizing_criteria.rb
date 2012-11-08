class SizingCriteria < ActiveRecord::Base
  
  belongs_to :sizing_criteria_category  
  has_many :project_sizing_criterias, :dependent => :destroy
  has_many :line_sizings
  
  validates_presence_of :sizing_criteria_category_id, :sizing_criteria_category_type_id, 
                        #:code, :velocity_min, :velocity_max, :delta_per_100ft_min, :delta_per_100ft_max, :user_notes,
						:name, :velocity_sel, :delta_per_100ft_sel
                        
  validates_numericality_of :velocity_sel, :delta_per_100ft_sel

                            
  validate :velocity_min_cannot_be_great_max, :delta_per_100ft_min_cannot_be_great_max, :velocity_sel_value_between_min_and_max, :delta_per_100ft_sel_value_between_min_and_max
  
  def velocity_min_cannot_be_great_max
    errors.add(:velocity_min, "can't be greaterthan velocity max value") if !velocity_min.nil? && (velocity_min.to_f > velocity_max.to_f)
  end
  
  def delta_per_100ft_min_cannot_be_great_max
    errors.add(:delta_per_100ft_min, "can't be greaterthan delta/100ft max value") if !delta_per_100ft_min.nil? && (delta_per_100ft_min.to_f > delta_per_100ft_max.to_f)
  end
  
  def velocity_sel_value_between_min_and_max
    if !velocity_min.nil? && (velocity_sel >= velocity_min) && (velocity_sel <= velocity_max)
      errors.add(:velocity_sel, "should be between min and max value")
    end
  end
  
  def delta_per_100ft_sel_value_between_min_and_max
    if !delta_per_100ft_min.nil? && (delta_per_100ft_sel >= delta_per_100ft_min) && (delta_per_100ft_sel <= delta_per_100ft_max)
      errors.add(:delta_per_100ft_sel, "should be between min and max value")
    end    
  end
end
