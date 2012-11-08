class Title < ActiveRecord::Base

  has_many :users

  def to_s
    name
  end
end
