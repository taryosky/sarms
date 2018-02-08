class LoginSessionsController < ApplicationController
	
	before_action :require_login, only:[:destroy] 	#require_login method is defined in application_helper.rb
	
	def new	
	end

	def create
		user_name = params[:loginsession][:name]

		user_password = params[:loginsession][:password]

		user = LoginDetail.find_by(user_name: user_name)

		if user && user.password == user_password.strip
			user_type = user.user_type
			user_table_id = user.user_id
			case user_type
			when 0
				stud_user = Student.find_by(id: user_table_id)
				if(stud_user)
					login_stud(stud_user)
					activation = LoginDetail.find_by(user_name: stud_user.matno).activation
					
					#Update the login log file
					file = File.open( Rails.root.join('log', "login.log"), 'a')
					file.syswrite("\t\tStudent signed in\n=====================================\nUsername: #{stud_user.matno.titlecase}\nDate/time: #{Time.now}\n\n\n")
					file.close
					
					if activation < 3
						redirect_to student_update_path #students_path
					else
						redirect_to student_notifications_path
					end
				else
					flash[:message] = "SORRY YOU ARE NO LONGER A STUDENT OF THIS DEPARTMENT PLEASE GO A REGISTER AS A STUDENT"
					redirect_to user_login_path
				end
			when 1
				lect_user = Lecturer.find_by(id: user_table_id)
				if(lect_user)
					login_lect(lect_user)
					activation = LoginDetail.find_by(user_name: lect_user.staff_id).activation
					#Update the login log file
					file = File.open( Rails.root.join('log', "login.log"), 'a')
					file.syswrite("\t\tLecturer signed in\n=====================================\nUsername: #{lect_user.staff_id.titlecase}\nDate/time: #{Time.now}\n\n\n")
					file.close
					if activation < 3
						redirect_to lecturer_update_path #students_path
					else
						redirect_to lecturer_notifications_path
					end
				else
					flash[:message] = "SORRY YOU ARE NO LONGER A LECTURER OF THIS DEPARTMENT"
					redirect_to user_login_path
				end
			when 2 
				admin_user = Admin.find_by(id: user_table_id)
				if(admin_user)
					login_admin(admin_user)
					
					#Update the login log file
					file = File.open( Rails.root.join('log', "login.log"), 'a')
					file.syswrite("\t\tAdmin signed in\n=====================================\nUsername: #{admin_user.name.titlecase}\nDate/time: #{Time.now}\n\n\n")
					file.close
					
					redirect_to admin_index_path
				else
					flash[:message] = "SORRY ADMIN PREVILAGES NOT GRANTED"
					redirect_to user_login_path
				end
			end
		else
			flash[:error] = "USER NAME OR PASSWORD IS INCORRECT PLEASE TRY AGAIN"
			redirect_to user_login_path
		end
	end

	def destroy
		logout get_user
		redirect_to user_login_path
	end
	
end