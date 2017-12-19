module AdminActivitiesHelper
	def current_admin
		return @current_admin ||= Admin.find_by(id: session[:admin_id])
	end
end
