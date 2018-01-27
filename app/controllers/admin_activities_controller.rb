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
  	@_100_level_students = Student.where('level = 100')
  	@_200_level_students = Student.where('level = 200')
  	@_300_level_students = Student.where('level = 300')
  	@_400_level_students = Student.where('level = 400')
  	@_500_level_students = Student.where('level = 500')
	
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
    end

  end

  def news
	@news = News.all.reverse
	respond_to do|format|
		format.js
    end
  end

  def checkcode
    stat = Hash.new
    pres_val = params[:past_val]
    query = params[:query]
    query_short = query[0..5]
    course =  Course.find_by(ccode: query_short)

    if course
      if query.match(/[A-Z]{3}\d{3}\s?-\s?(LAB$|(EN[1-9]$|ENLH[1-2]$))/)
        stat[:hall] = query.split('-')[1].strip();
        stat[:response] = true
        stat[:value] = pres_val
      else
        stat[:response] = false
        stat[:value] = pres_val
      end
    else
      stat[:response] = false
      stat[:value] = pres_val
    end
    
    respond_to do |format|
      format.json{render json: stat.to_json}
    end
    return @response
  end

#CAUTION!!! HIGHLY LOGICAL UNIT FULL UNDERSTANDING
#OF WORKING REQUIRED, BEFORE ATEMPT TO MODIFY
#ALL TIME TABLE SETTING EDITING AND UPDATING IS DONE HERE
  def set_time_table
    empty_content = false #use to determine wether or not to set the element value to "", this is done when the course code don't exits
    value = params[:value]
    day = params[:day]
    per = params[:period]
    hall = params[:hall]
    row = params[:row].to_i
    pres_val = value
    past_val = params[:past_val]

    code = value[0..5]

    code.empty? ? temp=past_val[0..5] : temp=code #assign the course from either the past value or the value passed

    #if either a past value or a value exits for the code
    if !temp.empty?
      course1 = Course.find_by(ccode: pres_val[0..5])
      course2 = Course.find_by(ccode: past_val[0..5])

      t_per = Array.new()

      ttable = TimeTable.all
      ttable.each do |p|
        t_per.push(p.period)
      end

      cors = Course.find_by(ccode: temp)
      id = cors.id if cors

      course_on_time_table = TimeTable.find_by(course_id: id, period: per, day: day)
     
      #if both the present value and the past are empty
      if(pres_val.empty? && past_val.empty?)
        value = ""
      #if both the present value id not empty and the past is empty
      elsif(!pres_val.empty? && past_val.empty?)
        if course_on_time_table
          value = ""
          empty_content = true
        else
          status = true
          if ttable.size > 0
            ttable.each do |time_table|
              if (time_table.day==day && time_table.period.to_s == per) && ((Course.find_by(id: time_table.course_id).level == Course.find_by(id: id).level) || (time_table.hall==hall))
                  status = false
              end
            end
            if status
              TimeTable.create(course_id: id, period: per, day: day, row: row, hall: hall)
              value = pres_val
            else
              value = ""
              empty_content = true
            end
          else
            TimeTable.create(course_id: id, period: per, day: day, row: row, hall: hall)
            value = pres_val
          end
        end
      #if the present value is empty and the past is not empty
      elsif (pres_val.empty? && !past_val.empty?)
        if course_on_time_table
          empty_content = true
          value=""
          course_on_time_table.destroy
        end
      #if both the present value is not empty and the past is not empty
      elsif (!pres_val.empty? && !past_val.empty?)
        #check id both present and past value are thesame
        if (pres_val==past_val)
          if(course_on_time_table)
            
          elsif id && !course_on_time_table
            TimeTable.create(course_id: id, period: per, day: day, row: row, hall: hall)
          end
        else
          past_hall = past_val.split('-')[1].strip

          id2 = course2.id if course2

          past_course = TimeTable.find_by(course_id: id2, period: per, day: day, hall: past_hall)

          status = true
          
          if ttable.size > 0
            ttable.each do |time_table|
              if (time_table.day==day && time_table.period.to_s == per) && ((Course.find_by(id: time_table.course_id).level == Course.find_by(id: id).level) || (time_table.hall==hall))
                  status = false
              end
            end
            if status
              past_course.update(course_id: id, period: per, day: day, row: row, hall: hall)
              value = pres_val
            else
              value = past_val
              empty_content = 1
            end
          else
            past_course.update(course_id: id, period: per, day: day, row: row, hall: hall)
            value = pres_val
          end
        end
      end

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
    
    respond_to do |format|
      format.json{render json: empty_content}
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