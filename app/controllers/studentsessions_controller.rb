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
		
		#gather assignment notification if any notification on assingment is available
		assignments = ""
		submissions = AssignmentSubmission.where("student_id = ?", current_student.id)
		ass = Array.new
		submissions.each do|as_id|
			ass.push as_id.assignment_id
		end
		assign = Assignment.where.not(id: ass).where("submission_date > ?", Time.now)
		assignments = assign.size
		reg = Array.new
		assign.each do|ass|
			regist = Registration.where("session = ? AND student_id = ? AND course_id = ?", current_session, current_student.id, ass.id);
			reg.push(regist) if !regist.empty?
		end
		if assignments !=0
			temp_notice["assign"] = assignments
		end
		
		#get messages notifications for unread messages
		
		message_rec = MessageReceiver.where("receiver_id = ? AND read_status = ?", current_student.matno, 0).size
		if message_rec > 0
			temp_notice["message"] = message_rec
		end
		
		#set notification hash
		temp_notice.each do|key, val|
			if (!val.blank? || !val.nil? || !val) && !reg.empty?
				@notifications[key] = val
			end
		end
	end
end