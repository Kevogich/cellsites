class Role < ActiveRecord::Base

  has_and_belongs_to_many :users

  scope :identifier, lambda { |identifier| where( :identifier => identifier ).limit(1) }
  scope :identifiers, lambda { |identifiers| where( :identifier.in => identifiers ) }
  scope :general, where( :identifier.in => ['admin','project_setup','project_execution'] )

  def to_s
    name
  end
end
