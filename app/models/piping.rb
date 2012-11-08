class Piping < ActiveRecord::Base
  belongs_to :pipeable, :polymorphic => true
end
