class CompressorSizingTag < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit  
  has_many :compressor_sizing_modes, :dependent => :destroy
  has_many :compressor_sizings, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy

  acts_as_commentable
  
  validates_presence_of :compressor_sizing_tag, :project_id, :process_unit_id
end
