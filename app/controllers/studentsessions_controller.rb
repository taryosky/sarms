class StudentsessionsController < ApplicationController

	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_student_login				#require_admin_login is defined in login_sessions_helper.rb

	
	def new
		
	end

	def create
		student = Student.find_by(matno: params[:studentsession][:matno].downcase)
		if student #&& student.authenticate(params[:studentsession][:password])
			login_stud(student)
			redirect_to students_path
		else
		    flash[:error] = "Mat. No. or Password is not incorrect"
			redirect_to student_login_path
		end
	end

	def destroy
		logout_stud
		flash[:message] = "You are logged out"
		redirect_to user_login_path
	end

	def notification
		@notifications = Hash.new
		temp_notice = Hash.new
		
		assignments = ""
		
		submissions = AssignmentSubmission.where("student_id = ?", current_student.id)
		ass = Array.new
		submissions.each do|as_id|
			ass.push as_id.assignment_id
		end
		assignments = Assignment.where.not(id: ass).where("submission_date > ?", Time.now).size
		if assignments !=0
			temp_notice["assign"] = assignments
		end
		temp_notice.each do|key, val|
			if !val.blank? || !val.nil? || !val
				@notifications[key] = val
			end
		end
	end
end