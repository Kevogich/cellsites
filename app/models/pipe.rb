class Pipe < ActiveRecord::Base
  
  has_many :project_pipes  
  has_many :projects, :through => :project_pipes
  has_many :line_sizings
  
  validates_presence_of :material, :conditions, :roughness_min, :roughness_max, :roughness_recommended
  validates_numericality_of :roughness_min, :roughness_max, :roughness_recommended
  
  validate :roughness_min_cannot_be_great_max, :roughness_recommended_value_between_min_and_max

  def roughness_range
    "#{roughness_min} - #{roughness_max}"
  end
  
  def material_conditions
    "#{material} - (#{conditions})"
  end
  
  #validations
  def roughness_min_cannot_be_great_max
    errors.add(:roughness_min, "can't be greater than roughness max value") if !roughness_min.nil? && (roughness_min.to_f > roughness_max.to_f)
  end  
  
  def roughness_recommended_value_between_min_and_max    
    if(roughness_max.to_f <= roughness_recommended.to_f)
      errors.add(:roughness_recommended, "should be between min and max roughness values")
    end
    if(roughness_recommended.to_f <= roughness_min.to_f)
      errors.add(:roughness_recommended, "should be between min and max roughness values")
    end
  end
end
