class AttendancesController < ApplicationController
	
	before_action :require_login 					#require_login method is defined in application_helper.rb
	before_action :require_lecturer_login			#require_admin_login is defined in login_sessions_helper.rb


	def index
		@courses = current_lecturer.courses
		@counter = 1
	end

	def print
		@counter =1;
		@course = Course.find_by(id: params[:course][:course_id])
		@reg = Student.select(:matno, :sname, :fname).joins(:registrations).where("course_id == ? AND session == ? AND status > ?", @course.id, current_session, 0)
	end
	
end