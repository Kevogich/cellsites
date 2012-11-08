module Admin::UserProjectSettingsHelper

	def user_clients(user)
		c = []
		user.projects.each do |p|
			c << p.client
		end
		return c
	end
end
