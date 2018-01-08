class StudentsController < ApplicationController
	
	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_admin_login, only:[:create, :update, :delete, :print_passwords, :search]	#require_admin_login is defined in login_sessions_helper.rb
	before_action :require_student_login, only:[:update_info, :update_student_info, :change_passport, :change_password, :profile_view]				#require_admin_login is defined in login_sessions_helper.rb
	
	
	def create
	@student = Student.new 
	@student_matno = params[:matno]
	@student_sname = params[:sname]
	@student_fname = params[:fname]
	@student_othernames = params[:othernames]
	@student_level = params[:level]
	@students = Hash.new
	@student_othernames_hash = Hash.new
	@student_matno.each do|key, value|
		num = (key.slice(key.length-1)).to_i
		student = Student.new
		student_othernames = StudentOthername.new
		student.matno = value
		student.sname = @student_sname["sname#{num}"]
		student.fname = @student_fname["fname#{num}"]
		student.level = @student_level["level#{num}"]
		student_othernames.othernames = @student_othernames["othernames#{num}"]
		@students["index#{num}"] = student
		@student_othernames_hash["index#{num}"] = student_othernames if !student_othernames.nil?
	end
	
	@invalid_students = Hash.new
	@students.each do|key, value|
		if !value.valid?
			num = (key.slice(key.length-1)).to_i
			array = Array.new
			if !value.errors[:matno].empty?
				array.push "Matric. No"
			end
			if !value.errors[:sname].empty?
				array.push "Surname"
			end
			if !value.errors[:fname].empty?
				array.push "First Name"
			end
			if !value.errors[:level].empty?
				array.push "Level"
			end
			@invalid_students[num] = array
		end
	end
	
	if @invalid_students.empty?
		@students.each do|key, value|
			value.save
			@password = gen_login_password value
			if @student_othernames_hash[key] != nil
				@student_othernames_hash[key].student_id = value.id
				@student_othernames_hash[key].save
			end
		end
		#Update the login log file
		file = File.open( Rails.root.join('log', "create_new.log"), 'a')
		file.syswrite("\t\t#{@students.size} Student(s) Created\n=====================================\nDate/time: #{Time.now}\n\n\n")
		file.close
	end
		
		@counter = 1
		@_100_level_students = Student.where('level = ?', 100)
		@_200_level_students = Student.where('level = ?', 200)
		@_300_level_students = Student.where('level = ?', 300)
		@_400_level_students = Student.where('level = ?', 400)
		@_500_level_students = Student.where('level = ?', 500)
		
	    respond_to do|format|
	        format.html
	        format.js
	    end
	end
	
	def update_info
		@matno = current_student.matno
		@activation = LoginDetail.find_by(user_name: @matno).activation
		@student = current_student
	end
	
	def update_student_info
		@activation = LoginDetail.find_by(user_name: current_student.matno).activation
		@student = current_student
		@student_login = LoginDetail.find_by(user_name: @student.matno)
		
		if @activation == 0
			if @student.update edit_student_params
				@student_login.activation = 1
				@student_login.save
				@student_othername = StudentOthername.find_by(student_id: current_student.id)
				@othername = params[:edit_student][:othernames]
				if !@othername.blank?
					if @student_othername.nil?
						StudentOthername.create(student_id: @student.id, othernames: @othername)
					else
						@student_othername.othernames = @othername
						@student_othername.save
					end
				end
				flash[:success] = "Data Successfully Updated"
				redirect_to student_update_path
			else
				render "update_info"
			end
		elsif @activation == 1
			@passport = nil 
			if params[:student_passport]
				@passport = params[:student_passport][:passport]
			end
			if @passport.blank?
				flash.now[:error] = "You can't submit a blank file"
				render "update_info"
			else
				upload_passport @passport, current_student
				@student_login.activation = 2
				@student_login.save
				flash[:success] = "Passport Successfully Uploaded"
				redirect_to student_update_path
			end
		elsif @activation == 2
			@password = params[:student_password][:password]
			@password_c = params[:student_password][:password_c]
			@verify = verify_password @password, @password_c
			if @verify == 1
				@student_login.password = @password
				@student_login.activation = 3
				@student_login.save
				flash[:success] = "Profile Update Completed. You can now proceed by clicking the finish button"
				flash[:successful] = ""
				redirect_to student_profile_path
			else
				flash.now[:error] = @verify
				render "update_info"
			end
		else
			redirect_to student_notifications_path
		end
	end
	
	def profile_view
	end
	
	def change_passport
		@passport = nil 
		if params[:student_passport]
			@passport = params[:student_passport][:passport]
		end
		if @passport.blank?
			flash.now[:error] = "You can't submit a blank file"
			render "update_info"
		else
			upload_passport @passport, current_student
			flash[:success] = "Passport Successfully Uploaded"
		end
		redirect_to student_profile_path
	end
	
	def change_password
		old_pass = params[:student_password][:opassword]
		new_pass = params[:student_password][:password]
		login = LoginDetail.find_by(user_name: current_student.matno)
		if old_pass == login.password
			login.password = new_pass
			login.save
			flash[:success] = "Password successfully changed"
		else
			flash[:error] = "The old password you provided is not correct"
		end
		redirect_to student_profile_path
	end

	
	def update
		@other_names = params[:edit_student][:othernames]
	    @student = Student.find_by(id:params[:edit_student][:id])
	    @student_other_names = @student.student_othername

	    if @student.update(edit_student_params) && !(@other_names.blank?)
			if @student_other_names.nil?
				student_othernames = StudentOthername.new othernames:@other_names
				student_othernames.student = @student
				student_othernames.save
			else
				@student_other_names.othernames = @other_names
				@student_other_names.save
			end
		else
			if !@student.student_othername.nil?
				@student.student_othername.destroy
			end
	    end
		
		@counter = 1
		@_100_level_students = Student.where('level = ?', 100)
		@_200_level_students = Student.where('level = ?', 200)
		@_300_level_students = Student.where('level = ?', 300)
		@_400_level_students = Student.where('level = ?', 400)
		@_500_level_students = Student.where('level = ?', 500)
		
	    respond_to do|format|
	        format.html
	        format.js
	    end
	end
	
	def delete
		@student = Student.find_by(id: params[:edit_student][:id])
		@student_login_detail = LoginDetail.where("user_id = ? AND user_type = ?", @student.id, @student.user_type).first
		if @student
			@student_login_detail.destroy
			@student.destroy
			respond_to do|format|
				format.js
			end
		end
		@counter = 1
		@_100_level_students = Student.where('level = ?', 100)
		@_200_level_students = Student.where('level = ?', 200)
		@_300_level_students = Student.where('level = ?', 300)
		@_400_level_students = Student.where('level = ?', 400)
		@_500_level_students = Student.where('level = ?', 500)
	end
	
	def search
		@param = params[:search][:student]
		@search_student = Student.where("phone LIKE ? OR email LIKE ? OR state_of_origin LIKE ? OR matno LIKE ? OR lga LIKE ? OR fname LIKE ? OR sname LIKE ?", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%");
		respond_to do|format|
			format.js
		end
	end
	
	def print_passwords
		@passwords = LoginDetail.select(:user_id, :password).where("user_type = ? AND activation = ?", 0, 0)
	end

end

def new_student_params
	params.require(:create_student).permit(:matno, :fname, :sname, :state_of_origin, :nationality, :lga, :sex, :email, :phone, :religion, :level)
end

def edit_student_params
	params.require(:edit_student).permit(:matno, :fname, :sname, :state_of_origin, :nationality, :lga, :sex, :email, :phone, :religion)
end



