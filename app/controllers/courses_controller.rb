class CoursesController < ApplicationController

	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_admin_login			#require_admin_login is defined in login_sessions_helper.rb


  def search
	@param = params[:search][:course]
	@search_courses = Course.where("ccode LIKE ? OR ctitle LIKE ? OR level LIKE ?", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%");
	respond_to do|format|
		format.js
	end
  end

  def delete
    @course = Course.find_by(id: params[:edit_course][:id])
    if @course
        @val = @course.destroy!
    end
    respond_to do|format|
        format.js
    end
  end

  def update
	@course = Course.find_by(id:params[:edit_course][:id])	
	@course.update(edit_course_params)	
	respond_to do|format|
		format.js
		format.html
	end
	@courses = Course.all
	@lecturers = Lecturer.all
  end

  def create
	@largestId = nil
	@course = Course.new 
	@course_code = params[:code]
	@course_title = params[:title]
	@course_unit = params[:units]
	@course_semest = params[:semester]
	@course_level = params[:level]
	@course_status = params[:status]
	@courses = Hash.new
	@course_code.each do|key, value|
		num = (key.slice(key.length-1)).to_i
		course = Course.new
		course.ccode = value
		course.ctitle = @course_title["ctitle#{num}"]
		course.units = @course_unit["units#{num}"]
		course.semester = @course_semest["semester#{num}"]
		course.level = @course_level["level#{num}"]
		course.status = @course_status["status#{num}"]
		@courses["index#{num}"] = course
		@largestId = num
	end
	
	@invalid_courses = Hash.new
	@courses.each do|key, value|
		if !value.valid?
			num = (key.slice(key.length-1)).to_i
			array = Array.new
			if !value.errors[:ccode].empty?
				array.push "Course Code"
			end
			if !value.errors[:ctitle].empty?
				array.push "Course Title"
			end
			if !value.errors[:units].empty?
				array.push "Units"
			end
			if !value.errors[:level].empty?
				array.push "Level"
			end
			if !value.errors[:semester].empty?
				array.push "Semester"
			end
			if !value.errors[:status].empty?
				array.push "Status"
			end
			@invalid_courses[num] = array
		end
	end
	
	if @invalid_courses.empty?
		@courses.each do|key, value|
			value.save
		end
		#Update the login log file
			file = File.open( Rails.root.join('log', "create_new.log"), 'a')
			file.syswrite("\t\t#{@courses.size} Course(s) Created\n=====================================\nDate/time: #{Time.now}\n\n\n")
			file.close
	end
	
	
	respond_to do|format|
		format.html
		format.js
	end
	@courses = Course.all
	@lecturers = Lecturer.all
  end
  

  def edit_course_params
    params.require(:edit_course).permit(:id, :ccode, :ctitle, :units, :level, :semester)
  end

end


