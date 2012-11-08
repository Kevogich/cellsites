class CompressorReciprocationDesign < ActiveRecord::Base
  belongs_to :compressor_sizing
  has_many :compressor_reciprocation_design_pipings, :dependent => :destroy
  
  after_save :save_compressor_reciprocation_design_pipings
  accepts_nested_attributes_for :compressor_reciprocation_design_pipings, :allow_destroy => true
  
  def compressor_reciprocation_design_pipings=(crdp_params)
    @crdp_params = crdp_params
  end
  
  def save_compressor_reciprocation_design_pipings
    #raise @crdp_params.to_yaml   
    @crdp_params.each do |i, crdp_param|
      crdp = compressor_reciprocation_design_pipings.where(:id => crdp_param[:id]).first       
      compressor_reciprocation_design_pipings.create(crdp_param) if crdp.nil? && !crdp_param[:fitting].blank?      
      crdp.delete if !crdp.nil? && crdp_param[:fitting].blank? #delete
      crdp.update_attributes(crdp_param) if !crdp.nil? && !crdp_param[:fitting].blank? #update
    end if !@crdp_params.nil?
  end
end
