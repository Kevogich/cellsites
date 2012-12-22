class ProcureRfqSection < ActiveRecord::Base
  validates :name, :presence => true
  has_many :request_for_quotation_setups, :dependent => :delete_all
end
