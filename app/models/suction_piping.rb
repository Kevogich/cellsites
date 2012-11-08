class SuctionPiping < ActiveRecord::Base
  belongs_to :suction_pipe, :polymorphic => true
  has_one :stream_property_changer, :as => :stream_changable, :dependent => :destroy
  accepts_nested_attributes_for :stream_property_changer, :allow_destroy => true
end
