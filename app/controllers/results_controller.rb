class ResultsController < ApplicationController
	include ResultsHelper
	include StudentsHelper
	include LecturersHelper
	
	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_student_login

	def upload_results

	end

	def check_results
		@result_not_available = false
		@levels = Registration.select(:year_of_study).where("student_id = ? AND status > ?", current_student.id, 1).distinct
		@semester = Hash.new
		@levels.each do|lev|
			@semester[lev] = Course.select(:semester).joins(:registrations).select(:status).where("(student_id = ?) AND (year_of_study = ?)", current_student.id, lev.year_of_study).distinct
		end
		if @levels.empty?
			@result_not_available = true
		end
		
	end

	def view_student_results
		@level = params[:result][:level]
		@semester = params[:result][:semester]

		@counter = 1

		@semester_gp = 0
		@semester_units = 0
		@gpa = 0.00

		@cumulative_gp = 0
		@cumulative_units = 0
		@cgpa = 0.00
		
		registration = Registration.where('status > ?',1).where('year_of_study = ? AND student_id = ?', @level, current_student.id)
		
		@semester_reg = []
		registration.each do|reg|
			if reg.course.semester.to_i == @semester.to_i
				@semester_reg.push(reg)
				@semester_units += reg.units.to_i
				@semester_gp += get_grade_point reg
			end
		end

		all_registrations = Registration.where(student_id: current_student.id).where('year_of_study <= ? AND status > ?', @level, 1)
		
		#if registration.nil?
		
		registrations = []
		if @semester.to_i == 0
			all_registrations.each do|reg|
				if (reg.course.semester == 1) and (reg.year_of_study == @level.to_i)
				else
					registrations.push(reg)
				end
			end

			registrations.each do|reg|
				@cumulative_units += reg.units.to_i
				@cumulative_gp += get_grade_point reg
			end

		else
			all_registrations.each do|reg|
				@cumulative_units += reg.units.to_i
				@cumulative_gp += get_grade_point reg
			end
		end

		@gpa = @semester_gp/@semester_units
		@cgpa = @cumulative_gp/@cumulative_units

	end

	
end
