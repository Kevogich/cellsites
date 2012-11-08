class ActiveRecord::Base
	# a custom method added to active record instance to do the deep cloning
	# options must be an array of associations
	# for one level associations use the child model string
	#Example: 
	# === for first level deep =======
	#     p = PumpSizing.first
	#     c = p.deep_clone(["pipe_sizings"]) -- pump_sizing has_many pipe_sizings
	#     c.save
	# === for second level deep ========
	#     p = PumpSizing.first
	#     c = p.deep_clone(["circuit_pipings",{"discharge_pipings" =>"discharge_circuit_pipings"}]) 
	#     				-- pump_sizing has_many circuit_sizings
	#     				-- pump_sizing has_many discharge_pipings
	#     				-- each discharge_piping has_many discharge_circuit_pipings
	#     c.save
	def deep_clone(options)
		cloned_obj = self.clone
		options.each do |opt|
			if opt.is_a? String
				items = self.send(opt.to_sym)
				items.each do |i|
					eval "cloned_obj.#{opt} << i.clone"
				end
			elsif opt.is_a? Hash
				self.send(opt.keys[0].to_sym).each do |fi|
					fitem = fi.clone
					fi.send(opt.values[0].to_sym).each do |si|
						eval "fitem.#{opt.values[0]} << si.clone"
					end
					eval "cloned_obj.#{opt.keys[0]} << fitem"
				end
			end
		end
		return cloned_obj
	end
end
