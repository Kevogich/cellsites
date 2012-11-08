class CompanyUser < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  has_and_belongs_to_many :units
  belongs_to :group
  belongs_to :title
  has_many :attachments, :as => :attachable, :dependent => :destroy
  validates_presence_of :access_type_id

  delegate :name, :username, :email, :to => :user
  accepts_nested_attributes_for :user

  acts_as_commentable

  def unit_names
    units.map { |u| u.name }.join(', ')
  end

  def access_type
    [ "Read Only", "Read Write"][ access_type_id || 0 ]
  end

end
