class FlowElementDownstream < ActiveRecord::Base
  belongs_to :flow_element_sizing
  has_many :downstream_circuit_pipings, :class_name => 'FlowElementDownstreamCircuitPiping'
  has_many :flow_element_downstream_circuit_pipings, :dependent => :destroy
  
  after_save :save_downstream_circuit_pipings
    
  def downstream_circuit_pipings=(dcp_params)    
    @dcp_params = dcp_params
  end
    
  def save_downstream_circuit_pipings
    #raise @dcp_params.to_yaml
    @dcp_params.each do |i, dcp_param|
      dcp = flow_element_downstream_circuit_pipings.where(:id => dcp_param[:id]).first       
      flow_element_downstream_circuit_pipings.create(dcp_param) if dcp.nil? && !dcp_param[:fitting].blank?      
      dcp.delete if !dcp.nil? && dcp_param[:fitting].blank? #delete
      dcp.update_attributes(dcp_param) if !dcp.nil? && !dcp_param[:fitting].blank? #update      
    end if !@dcp_params.nil?
  end

end
