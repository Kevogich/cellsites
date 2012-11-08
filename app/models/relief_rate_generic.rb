class ReliefRateGeneric < ActiveRecord::Base

  belongs_to :scenario_identification


  acts_as_commentable
  has_many :attachments, :as => :attachable, :dependent => :destroy
end
