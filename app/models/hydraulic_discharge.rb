class HydraulicDischarge < ActiveRecord::Base
  belongs_to :hydraulic_turbine
  has_many :hydraulic_discharge_circuit_pipings, :dependent => :destroy
  
  after_save :save_hydraulic_discharge_circuit_pipings
  
  def hydraulic_discharge_circuit_pipings=(dcp_params)
     @dcp_params = dcp_params
  end
  
  def save_hydraulic_discharge_circuit_pipings
	  @dcp_params.each do |i, dcp_param|
      dcp = hydraulic_discharge_circuit_pipings.where(:id => dcp_param[:id]).first       
      hydraulic_discharge_circuit_pipings.create(dcp_param) if dcp.nil? && !dcp_param[:fitting].blank?  #create
      dcp.delete if !dcp.nil? && dcp_param[:fitting].blank? #delete
      dcp.update_attributes(dcp_param) if !dcp.nil? && !dcp_param[:fitting].blank? #update
    end if !@dcp_params.nil?
  end  

end
