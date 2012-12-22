class ItemTypesTransmitAndProposal < ActiveRecord::Base
  belongs_to :item_type
  validates :item_tag, :uniqueness => true
  has_many :attachments, :as => :attachable, :dependent => :destroy
  accepts_nested_attributes_for :attachments, :reject_if => lambda { |p| p[:attachment].blank? }, :allow_destroy => true

  has_many :comments, :dependent => :destroy
  accepts_nested_attributes_for :comments, :reject_if => lambda { |p| p[:comment].blank? }, :allow_destroy => true
  has_one :datasheet
  acts_as_commentable
end
