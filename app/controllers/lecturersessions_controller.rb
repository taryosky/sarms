class LecturersessionsController < ApplicationController
	
	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_lecturer_login			#require_admin_login is defined in login_sessions_helper.rb


	
	def new
	end

	def create
		lecturer = Lecturer.find_by(staff_id: params[:lecturersession][:staff_id].downcase)
		if lecturer #&& lecturer.authenticate(params[:lecturersession][:password])
			login_lect(lecturer)
			redirect_to lecturers_path
		else
			render plain: 'log in failed'
		end
	end

	def destroy
		logout_lect
		redirect_to user_login_path
	end

end