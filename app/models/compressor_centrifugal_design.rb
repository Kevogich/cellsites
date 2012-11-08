class CompressorCentrifugalDesign < ActiveRecord::Base
  belongs_to :compressor_sizing
  has_many :compressor_centrifugal_design_pipings, :dependent => :destroy
  
  #after_save :save_compressor_centrifugal_design_pipings

  accepts_nested_attributes_for :compressor_centrifugal_design_pipings, :allow_destroy => true
end 
