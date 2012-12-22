class RequestForQuotationSetup < ActiveRecord::Base
  belongs_to :project
  belongs_to :procure_rfq_section
  belongs_to :item_type
  has_many :attachments, :as => :attachable, :dependent => :destroy
  acts_as_commentable
end
