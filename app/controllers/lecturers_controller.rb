class LecturersController < ApplicationController

	before_action :require_login 			#require_login method is defined in application_helper.rb
	before_action :require_admin_login, only:[:create, :update, :delete, :print_passwords, :search]	#require_admin_login is defined in login_sessions_helper.rb
	before_action :require_lecturer_login, only:[:update_info, :update_lecturer_info, :profile_view, :change_password, :change_passport]				#require_admin_login is defined in login_sessions_helper.rb
	
	def create
	@lecturer = Lecturer.new 
	@lecturer_title = params[:title]
	@lecturer_staff_id = params[:staff_id]
	@lecturer_sname = params[:sname]
	@lecturer_fname = params[:fname]
	@lecturer_othernames = params[:othernames]
	@lecturers = Hash.new
	@lecturer_othernames_hash = Hash.new
	@lecturer_title.each do|key, value|
		num = (key.slice(key.length-1)).to_i
		lecturer = Lecturer.new
		lecturer_othernames = LecturerOthername.new
		lecturer.title = value
		lecturer.staff_id = @lecturer_staff_id["staff_id#{num}"]
		lecturer.sname = @lecturer_sname["sname#{num}"]
		lecturer.fname = @lecturer_fname["fname#{num}"]
		lecturer_othernames.othernames = @lecturer_othernames["othernames#{num}"]
		@lecturers["index#{num}"] = lecturer
		@lecturer_othernames_hash["index#{num}"] = lecturer_othernames if !lecturer_othernames.nil?
	end
	
	@invalid_lecturers = Hash.new
	@lecturers.each do|key, value|
		if !value.valid?
			num = (key.slice(key.length-1)).to_i
			array = Array.new
			if !value.errors[:staff_id].empty?
				array.push "Staff Id"
			end
			if !value.errors[:sname].empty?
				array.push "Surname"
			end
			if !value.errors[:fname].empty?
				array.push "First Name"
			end
			@invalid_lecturers[num] = array
		end
	end
	
	
	if @invalid_lecturers.empty?
		@lecturers.each do|key, value|
			value.save
			@password = gen_login_password value
			if @lecturer_othernames_hash[key] != nil
				@lecturer_othernames_hash[key].lecturer_id = value.id
				@lecturer_othernames_hash[key].save
			end
		end
		#Update the login log file
		file = File.open( Rails.root.join('log', "create_new.log"), 'a')
		file.syswrite("\t\t#{@lecturers.size} Lecturer(s) Created\n=====================================\nDate/time: #{Time.now}\n\n\n")
		file.close
	end
		
				
	    respond_to do|format|
	        format.html
	        format.js
	    end
		@lecturers = Lecturer.all
	end
	
	def update
	    @other_names = params[:edit_lecturer][:othernames]
	    @lecturer = Lecturer.find_by(id:params[:edit_lecturer][:id])
	    @lecturer_other_names = @lecturer.lecturer_othername

	    if @lecturer.update(edit_lecturer_params) && !(@other_names.blank?)
			if @lecturer_other_names.nil?
				lecturer_othernames = LecturerOthername.new othernames:@other_names
				lecturer_othernames.lecturer = @lecturer
				lecturer_othernames.save
			else
				@lecturer_other_names.othernames = @other_names
				@lecturer_other_names.save
			end
		else
			if !@lecturer.lecturer_othername.nil?
				@lecturer.lecturer_othername.destroy
			end
	    end
		
	    respond_to do|format|
	        format.html
	        format.js
	    end
		@lecturers = Lecturer.all
	end
	
	
	
	def delete
		@lecturer = Lecturer.find_by(id: params[:edit_lecturer][:id])
		@lecturer_login_detail = LoginDetail.where("user_id = ? AND user_type = ?", @lecturer.id, @lecturer.user_type).first

		if @lecturer
			@lecturer.destroy
			@lecturer_login_detail.destroy
			respond_to do|format|
				format.js
			end
		end
		@lecturers = Lecturer.all
	end
	
	
	
	def update_info
		@staff_id = current_lecturer.staff_id
		@activation = LoginDetail.find_by(user_name: @staff_id).activation
		@lecturer = current_lecturer
		if @activation > 2
			redirect_to lecturer_prof_path
		end
	end
	
	def update_lecturer_info
		@activation = LoginDetail.find_by(user_name: current_lecturer.staff_id).activation.to_i
		@lecturer = current_lecturer
		@lecturer_login = LoginDetail.find_by(user_name: @lecturer.staff_id)
		
		if @activation == 0
			if @lecturer.update edit_lecturer_params
				@lecturer_login.activation = 1
				@lecturer_login.save
				@lecturer_othername = LecturerOthername.find_by(lecturer_id: current_lecturer.id)
				@othername = params[:edit_lecturer][:othernames]
				if !@othername.blank?
					if @lecturer_othername.nil?
						LecturerOthername.create(lecturer_id: @lecturer.id, othernames: @othername)
					else
						@lecturer_othername.othernames = @othername
						@lecturer_othername.save
					end
				end
				flash[:success] = "Data Successfully Updated"
				redirect_to lecturer_update_path
			else
				render "update_info"
			end
		elsif @activation == 1
			@passport = nil 
			if params[:lecturer_passport]
				@passport = params[:lecturer_passport][:passport]
			end
			if @passport.blank?
				flash.now[:error] = "You can't submit a blank file"
				render "update_info"
			else
				upload_passport @passport, current_lecturer
				@lecturer_login.activation = 2
				@lecturer_login.save
				flash[:success] = "Passport Successfully Updated"
				redirect_to lecturer_update_path
			end
		elsif @activation == 2
			@password = params[:lecturer_password][:password]
			@password_c = params[:lecturer_password][:password_c]
			@verify = verify_password @password, @password_c
			if @verify == 1
				@lecturer_login.password = @password
				@lecturer_login.activation = 3
				@lecturer_login.save
				flash[:success] = "Congratulationss, Profile Completed. You can now proceed by clicking finish"
				flash[:successful] = ""
				redirect_to lecturer_profile_path
			else
				flash.now[:error] = @verify
				render "update_info"
			end
		else
			redirect_to lecturer_notifications_path
		end
	end
	
	def profile_view
	end
	
	def change_passport
		@passport = nil 
		if params[:lecturer_passport]
			@passport = params[:lecturer_passport][:passport]
		end
		if @passport.blank?
			flash.now[:error] = "You can't submit a blank file"
			render "update_info"
		else
			upload_passport @passport, current_lecturer
			flash[:success] = "Passport Successfully Uploaded"
		end
		redirect_to lecturer_profile_path
	end
	
	def change_password
		old_pass = params[:lecturer_password][:opassword]
		new_pass = params[:lecturer_password][:password]
		login = LoginDetail.find_by(user_name: current_lecturer.staff_id)
		if old_pass == login.password
			login.password = new_pass
			login.save
			flash[:success] = "Password successfully changed"
		else
			flash[:error] = "The old password you provided is not correct"
		end
		redirect_to lecturer_profile_path
	end
	
	
	
	def search
		@param = params[:search][:lecturer]
		@search_lecturers = Lecturer.where("phone LIKE ? OR email LIKE ? OR state_of_origin LIKE ? OR staff_id LIKE ? OR lga LIKE ? OR fname LIKE ? OR sname LIKE ?", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%", "%"+@param+"%");
		respond_to do|format|
			format.js
		end
	end
	
	def print_passwords
		@passwords = LoginDetail.select(:user_id, :password).where("user_type = ? AND activation = ?", 1, 0)
	end
end

 
def new_lecturer_params
    params.require(:create_lecturer).permit(:staff_id, :sname, :fname, :sex, :state_of_origin, :lga, :nationality, :religion, :phone, :email)
end

def edit_lecturer_params
    params.require(:edit_lecturer).permit(:staff_id, :sname, :fname, :sex, :state_of_origin, :lga, :nationality, :religion, :phone, :email)
end
