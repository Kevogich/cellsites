class HeatExchangerSizing < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable
  
  validates_presence_of :exchanger_tag, :project_id, :process_unit_id
  
  #convert values
  def convert_values(multiply_factor,project)
    
  end
end
