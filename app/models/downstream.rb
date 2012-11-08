class Downstream < ActiveRecord::Base
  belongs_to :downstream_design, :polymorphic => true
end
