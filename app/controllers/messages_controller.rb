class MessagesController < ApplicationController
	before_action :require_login
	
	def send_message(sender, receiver)
	end
	
	def inbox
		@current_user = get_user
		if @current_user.user_type == 0
			@messages = MessageReceiver.where("receiver_id = ?", @current_user.matno).reverse
		elsif @current_user.user_type == 1
			@courses = Hash.new
			@receiver = Hash.new
			@messages = MessageReceiver.where("receiver_id = ?", @current_user.staff_id).reverse
			alloc = CourseAllocation.where("lecturer_id = ?", @current_user.id)
			alloc.each do|value|
				course = Course.find_by(id: value.course_id)
				@courses[course.ccode] = course.id
				@receiver["Students"] = 0
				#@receiver["Lecturers"] = 1
				#@receiver["Admin"] = 2
			end
		else
		end
	end
	
	def delete
		counter = 0
		@param = params[:delete_message]
		@param.each do|key, value|
			if value == 1.to_s
				MessageReceiver.find_by(id: key).destroy
				counter +=1
			end
		end
		flash[:success] = counter.to_s + "#{counter ==1? ' Message':' Messages'} successfully deleted"
		redirect_to inbox_path
	end
	
	def create
		@message_title = params[:message][:title]
		@message_receiver = params[:message][:receiver]
		@message_content = params[:message][:message]
		@message_course = params[:message][:course]
		user = get_user
		if user.user_type == 0
			sender = user.matno
		elsif user.user_type == 1
			sender = user.staff_id
		else 
		end
		if !@message_title.blank? && !@message_content.blank?
			if @message_receiver == 0.to_s 
				if @message_course == nil
					flash[:error] = "An error occured please try again"
					redirect_to inbox_path
				else
					message = Message.create(title: @message_title, content: @message_content, sender_id: sender, date: Time.now)
					registrations = Registration.where("session=? AND course_id=? AND status=?",current_session, @message_course, 1)
					registrations.each do|reg|
						student_receiver = Student.find_by(id: reg.student_id)
						mreceiver = MessageReceiver.new
						mreceiver.receiver_id = student_receiver.matno
						mreceiver.read_status = 0
						mreceiver.message_id = message.id
						mreceiver.save
					end
					flash[:success] = "Your message has been sent"
					redirect_to inbox_path
				end
			elsif @message_receiver == 1.to_s
				lecturers = Lecturer.where("staff_id != ?", sender)
				message = Message.create(title: @message_title, content: @message_content, sender_id: sender, date: Time.now)
				lecturers.each do|lec|
					mreceiver = MessageReceiver.new
					mreceiver.receiver_id = lec.staff_id
					mreceiver.read_status = 0
					mreceiver.message_id = message.id
					mreceiver.save
				end
				flash[:success] = "Your message has been sent"
				redirect_to inbox_path
			end
		else
		end
	end
	
	def message
		mess = params[:message].length
		message_id = params[:message].to_s.slice(-mess, mess-20)

		message_rec = MessageReceiver.find_by(id: message_id)
		if message_rec.nil?
			redirect_to inbox_path
		else
			@message = message_rec.message
			senderLog = LoginDetail.find_by(user_name: message_rec.message.sender_id)
			if senderLog.user_type == 0
				msender = Student.find_by(matno: senderLog.user_name)
				@sender = "#{msender.sname} #{msender.fname}"
			elsif senderLog.user_type == 1
				msender = Lecturer.find_by(staff_id: senderLog.user_name)
				@sender = "#{msender.title} #{msender.fname.slice(0).capitalize}. #{msender.sname}"
			else
				@sender = "Admin"
			end
			
			message_rec.read_status = 1
			message_rec.save
		end
		
	end
end
