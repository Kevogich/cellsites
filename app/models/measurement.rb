class Measurement < ActiveRecord::Base
  belongs_to :company #TODO need to delete association
  has_many :measure_units
  has_many :measurement_sub_types, :dependent => :destroy
  has_many :unit_of_measurements, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
end
