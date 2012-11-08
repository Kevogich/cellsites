class CompressorSizingMode < ActiveRecord::Base
  belongs_to :compressor_sizing_tag
  has_many :compressor_sizings, :dependent => :destroy
end
