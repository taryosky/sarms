class RegistrationsController < ApplicationController

	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_student_login		#require_admin_login is defined in login_sessions_helper.rb


	def index
		
	end

	def new
		redirect_to student_notifications_path if Util.where("name = ?", "registration").first.value.to_i != 1
		@counter = 1
		student = current_student
		@course_ids = []
		
		@registered = Registration.where("student_id = ? AND session = ?",current_student.id, current_session)
		
		#get all the failed and carryover couses from the previous session
		@course_to_reg = student.registrations.where(session: previous_session).where(status: [0,3])
		@course_to_reg.each do |d|
			@course_ids.push(d.course_id)
		end

		@fscc = Course.where(id: @course_ids).where(semester: 0)
		@sscc = Course.where(id: @course_ids).where(semester: 1)

		@first_semester_courses = Course.where(level: student.level).where(semester: 0)
		@second_semester_courses = Course.where(level: student.level).where(semester: 1)
	end

	def create

		@reg_courses = params.require(:course)
		
		student = current_student
		level = current_student.level
		#get all the course ids for fialed and carryover courses last session for both semesters
		@rep_courses = student.registrations.select(:course_id).where(session: previous_session).where(status: [0,3])
		@current_courses = Course.select(:id).where(level: level)
		@all_courses = []

		@rep_courses.each do|reg|
			@all_courses.push(reg.course_id)
		end

		@current_courses.each do|course|
			@all_courses.push(course.id)
		end

		@courses_to_reg = []
		@reg_courses.each do|key, val|
			@courses_to_reg.push(val)
		end

		@all_courses.each do|course|
			if @courses_to_reg.include?(course.to_s)
				course_r = Course.find_by(id: course)
				reg = Registration.create(student_id: current_student.id, course_id: course, session: current_session, year_of_study: level, status: :reg, units: course_r.units)
			else
				course_r = Course.find_by(id: course)
				reg = Registration.create(student_id: current_student.id, course_id: course, session: current_session, year_of_study: level, status: :not_reg, units: course_r.units)

			end
		end
		flash[:success] = "You've successfully registered for this session"
		redirect_to student_notifications_path
	end

	def edit

	end

	def show

	end

	def update

	end
end
