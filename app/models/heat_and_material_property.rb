class HeatAndMaterialProperty < ActiveRecord::Base
  belongs_to :heat_and_material_balance
  has_many :streams
end
