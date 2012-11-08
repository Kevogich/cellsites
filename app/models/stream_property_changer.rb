class StreamPropertyChanger < ActiveRecord::Base
	belongs_to :stream_changable, :polymorphic => true
end
