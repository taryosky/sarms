module ApplicationHelper
	def gen_login_password(user)
		user_activation_status = user.user_type == 2 ? 1 : 0
		@user_name = ""
		if user.user_type == 0
			@user_name = user.matno
		elsif user.user_type == 1
			@user_name = user.staff_id
		else
			user.name
		end
		@user_password =  SecureRandom.hex(10)
		login_detail = LoginDetail.create(user_name: @user_name, user_id: user.id, user_type: user.user_type, activation: user_activation_status, password: @user_password)
		return @user_password
	end
	
	
	def upload_passport file, user
		uploaded_io = file
		file_name = user.user_type == 0 ? user.matno.split("/").join("_") : user.id
		new_file_name = file_name.to_s+File.extname(uploaded_io.original_filename)
		user_passport = user.passport
		if user_passport
			delete_passport user
			File.open( Rails.root.join('profile_images', new_file_name), 'wb') do | file | 
				file.write( uploaded_io.read)
			end
			user.passport = new_file_name
			user.save
		else
			File.open( Rails.root.join('profile_images', new_file_name), 'wb') do | file | 
				file.write( uploaded_io.read)
			end
			user.passport = new_file_name
			user.save
		end
	end

	def delete_passport(user)
		if user.user_type == 0
			if user.passport
				file = Rails.root.join("profile_images/"+student.passport)
				File::delete(file)
			end
		else
			if user.passport
				file = Rails.root.join("profile_images/"+student.passport)
				File::delete(file)
			end
		end
	end

	def verify_password pass, pass_c
		if pass.blank? || pass_c.blank?
			return "Both fields must be filled"
		elsif pass != pass_c
			return "Password do not match"
		elsif pass.size<6 || pass_c.size<6
			return "Password cant be less than 6 characters"
		else 
			return 1
		end
	end
	
end
