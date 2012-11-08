class Unit < ActiveRecord::Base

  has_and_belongs_to_many :company_users
end
