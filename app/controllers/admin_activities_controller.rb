class AdminActivitiesController < ApplicationController

  before_action :require_login 			#require_login method is defined in application_helper.rb
  before_action :require_admin_login		#require_admin_login is definded in login_sessions_helper.rb

  
  
  def index
	@course_ids = Array.new
	@lecturer_ids = Array.new
	CourseAllocation.all.each do|alloc|
		@course_ids.push alloc.course_id
		@lecturer_ids.push alloc.lecturer_id
	end
	
	file = File.open( Rails.root.join('log', "login.log"), 'r')
	@title_signin = file.readlines.first
	file = File.open( Rails.root.join('log', "login.log"), 'r')
	d = file.readlines[3].to_s.split(" ")
	date = d[1].split("-")
	time = d[2].split(":")
	@time_signin = Time.local(date[0].to_d, date[1].to_d,date[2].to_d, time[0].to_d, time[1].to_d, time[2].to_d)
	file.close
	
  if File::zero?( Rails.root.join('log', "create_new.log"))
    @title_create = "No creation activity has been done"
    @time_create = Time.now
  else
  	file = File.open( Rails.root.join('log', "create_new.log"), 'r')
  	@title_create = file.readlines.first.chop
  	file = File.open( Rails.root.join('log', "create_new.log"), 'r')
  	d = file.readlines[2].to_s.split(" ")
  	date = d[1].split("-")
  	time = d[2].split(":")
  	@time_create = Time.local(date[0].to_d, date[1].to_d,date[2].to_d, time[0].to_d, time[1].to_d, time[2].to_d)
  	file.close
  end
	
  end

   def dashboard
	    @course_ids = Array.new
		@lecturer_ids = Array.new
		CourseAllocation.all.each do|alloc|
			@course_ids.push alloc.course_id
			@lecturer_ids.push alloc.lecturer_id
		end
		
		file = File.open( Rails.root.join('log', "login.log"), 'r')
		@title_signin = file.readlines.first.chop
		file = File.open( Rails.root.join('log', "login.log"), 'r')
		d = file.readlines[3].to_s.split(" ")
		date = d[1].split("-")
		time = d[2].split(":")
		@time_signin = Time.local(date[0].to_d, date[1].to_d,date[2].to_d, time[0].to_d, time[1].to_d, time[2].to_d)
		file.close
		
  if File::zero?( Rails.root.join('log', "create_new.log"))
    @title_create = "No creation activity has been done"
    @time_create = Time.now
  else
    file = File.open( Rails.root.join('log', "create_new.log"), 'r')
    @title_create = file.readlines.first.chop
    file = File.open( Rails.root.join('log', "create_new.log"), 'r')
    d = file.readlines[2].to_s.split(" ")
    date = d[1].split("-")
    time = d[2].split(":")
    @time_create = Time.local(date[0].to_d, date[1].to_d,date[2].to_d, time[0].to_d, time[1].to_d, time[2].to_d)
    file.close
  end
		
		respond_to do|format|
			format.html{render layout:false}
			format.js
		end
   end

  def course
    @count = 0;
    @course = Course.all
	  @lecturer = Lecturer.all
    respond_to do|format|
        format.html{render layout:false}
        format.js
    end
  end

 def lecturer
	 @counter = 1
	 @lecturers = Lecturer.all
    respond_to do|format|
		format.js
    end
  end

  def student
  	@counter = 1
  	@_100_level_students = Student.where('level == ?', 100)
  	@_200_level_students = Student.where('level == ?', 200)
  	@_300_level_students = Student.where('level == ?', 300)
  	@_400_level_students = Student.where('level == ?', 400)
  	@_500_level_students = Student.where('level == ?', 500)
	
    respond_to do|format|
		format.js
    end
  end

  def setregstatus
    status = params[:status].to_i
    util_id = Util.find_by(name: 'registration').id
    Util.update(util_id, value: status)
  end

  def setsession
    session_val = params[:input]
    val1 = session_val.to_i+1
    value = "#{session_val}/#{val1.to_s}"
    util_id = Util.find_by(name: 'session').id
    Util.update(util_id, value: value)
  end

  def session_activities
    @level = "100"

    @alloc_courses = CourseAllocation.all
    
    session_val = Util.find_by(name: 'session').value.to_s
    @temp = session_val.split('/')

    @reg_stat = Util.find_by(name: "registration").value.to_i

    @lecturer = Lecturer.all
    @courses = Course.where(level: '100')

    path = "#{Rails.root}/public/time_table/time_table.json"
    file = File.new(path, 'r')
    @data = File.read(file)
    @json_data = JSON.parse(@data)

    respond_to do |format|
      format.js
      format.html{render layout:false}
    end

  end

  def news
	@news = News.all.reverse
	respond_to do|format|
		format.js
    end
  end

  def checkcode
    @response =""
    @query = params[:query]
    Course.find_by(ccode: @query) ? @response = true : @response = false
    respond_to do |format|
      format.js
      format.html{render layout:false}
      format.json{render json: @response.to_json}
    end
    return @response
  end

  def set_time_table
    value = params[:value]
    day = params[:day]
    per = params[:period]
    row = params[:row].to_i
    path = "#{Rails.root}/public/time_table/time_table.json"
    file = File.new(path, 'r')
    data = JSON.parse(File.read(file))
    file.close
    if data
      data[day][per][row] = value
      temp = data.to_json
      file = File.new(path,"w")
      if file.write(temp)
        file.close
      end
    else

    end
  end

  def get_time_table
    path = "#{Rails.root}/public/time_table/time_table.json"
    file = File.new(path, 'r')
    @data = File.read(file)
    @json_data = JSON.parse(@data)
    file.close
    respond_to do |format|
      format.js
      format.json{render json: @data}
    end
  end 

  def get_allocated_courses

    @courses = Course.all
    @alloc_courses = CourseAllocation.all
    @lecturer = Lecturer.all
    respond_to do |format|
      format.js
    end

  end

  def alloc_course

    @alloc_courses = CourseAllocation.all
    @courses = Course.all
    @level = params[:level]
    @level_courses = Course.where(level: @level)
    @lecturer = Lecturer.all

    ccode = params[:ccode]
    lect = params[:lecturer]
    lect_details = lect.split(" ")

    if lect_details.length==4
      title = "#{lect_details[0]} #{lect_details[1]}"
      lecturer = Lecturer.where(["title = ? and sname = ? and fname = ?", title, lect_details[2], lect_details[3]]) 
      lecturer_id = lecturer.first.id
    else
      lecturer = Lecturer.where(["title = ? and sname = ? and fname = ?", lect_details[0], lect_details[1], lect_details[2]])
      lecturer_id = lecturer.first.id
    end

    course_id = Course.find_by(id: ccode).id
    if !CourseAllocation.where(lecturer_id: lecturer_id, course_id: course_id).first
       CourseAllocation.create(lecturer_id: lecturer_id, course_id: course_id)     
    end
    render "get_courses.js"
  end

  def get_courses

    @alloc_courses = CourseAllocation.all
    @courses = Course.all
    @level = params[:data]
    @level_courses = Course.where(level: @level)
    @lecturer = Lecturer.all

    respond_to do |format|
      format.js
    end
  end

  def remove_lect
    lect_name = params[:lect_name]
    course_id = params[:course_id]

    @alloc_courses = CourseAllocation.all
    @courses = Course.all
    @level = params[:level]
    @level_courses = Course.where(level: @level)
    @lecturer = Lecturer.all

    lect_details = lect_name.split(" ")

    if lect_details.length==4
      title = "#{lect_details[0]} #{lect_details[1]}"
      lecturer = Lecturer.where(["title = ? and sname = ? and fname = ?", title, lect_details[2], lect_details[3]]) 
      lecturer_id = lecturer.first.id
    else
      lecturer = Lecturer.where(["title = ? and sname = ? and fname = ?", lect_details[0], lect_details[1], lect_details[2]])
      lecturer_id = lecturer.first.id
    end
    course_allocation = CourseAllocation.where(["lecturer_id = ? and course_id = ?", lecturer_id, course_id])
    if course_allocation
      course_allocation.first.destroy!
    end
    render "get_courses.js"
  end
end