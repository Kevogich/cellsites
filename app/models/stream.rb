class Stream < ActiveRecord::Base
  belongs_to :heat_and_material_property
  belongs_to :heat_and_material_balance
  
  attr_accessible :heat_and_material_property_id, :display_stream_no, :stream_no, :stream_value, :id, :created_at, :updated_at 
  attr_accessor :display_stream_no
  
  def display_stream_no
    stream_no.split('.').first rescue ""    
  end
  
  def self.get_stream_nos_by_process_basis(process_basis_id)
    heat_and_meterial_balance = HeatAndMaterialBalance.where(:id=>process_basis_id).first    
    @streams = heat_and_meterial_balance.heat_and_material_properties.first.streams if !heat_and_meterial_balance.nil?
    @streams = [] if heat_and_meterial_balance.nil?
    @streams
  end
end
