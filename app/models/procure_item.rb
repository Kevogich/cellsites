class ProcureItem < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :project
  belongs_to :process_unit
  belongs_to :item_type
  validates :item_tag, :uniqueness => true
  has_many :procure_item_purchase_items, :dependent => :destroy
  has_many :sizing_status_activities, :as => :sizing, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy
  accepts_nested_attributes_for :attachments, :reject_if => lambda { |p| p[:attachment].blank? }, :allow_destroy => true

  has_many :comments, :dependent => :destroy
  accepts_nested_attributes_for :comments, :reject_if => lambda { |p| p[:comment].blank? }, :allow_destroy => true

  accepts_nested_attributes_for :procure_item_purchase_items, :allow_destroy => true

  acts_as_commentable
end
