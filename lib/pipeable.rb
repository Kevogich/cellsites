module Pipeable
  def is_pipeable
    has_many :pipings, :as => :pipeable, :dependent => :destroy
    accepts_nested_attributes_for :pipings, :reject_if => lambda { |p| p[:fitting].blank? }, :allow_destroy => true
    include InstanceMethods
  end
  module InstanceMethods
    def pipeable?
      true
    end
  end
end
ActiveRecord::Base.extend Pipeable