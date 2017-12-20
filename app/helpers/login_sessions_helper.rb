module LoginSessionsHelper
	def logout user
		if user.user_type == 0
			session.delete(:student_id)
			if session[:lecturer_id]
				session.delete(:lecturer_id)
			end
			if session[:admin_id]
				session.delete(:admin_id)
			end
			flash[:error] = "You are logged out"
			redirect_to user_login_path
		elsif user.user_type == 1
			if session[:student_id]
				session.delete(:student_id)
			end
			if session[:admin_id]
				session.delete(:admin_id)
			end
			session.delete(:staff_id)
			flash[:error] = "You are logged out"
			redirect_to user_login_path
		else
			session.delete(:admin_id)
			if session[:lecturer_id]
				session.delete(:lecturer_id)
			end
			if session[:student_id]
				session.delete(:student_id)
			end
			flash[:error] = "You are logged out"
			redirect_to user_login_path
		end
	end
	
	def require_login
		if !(current_student || current_lecturer || session[:admin_id])
			flash[:error] = "You are not logged in, please login"
			redirect_to user_login_path
		end
	end
	
	def require_admin_login
		if !session[:admin_id]
			if session[:staff_id]
				logout current_lecturer
			end
			if session[:student_id]
				logout current_student
			end
			flash[:error] = "Sorry, you are automatically logged out because of malicious activities"
		end
	end
	
	def require_student_login
		if !session[:student_id]
			if session[:staff_id]
				logout current_lecturer
			end
			if session[:admin_id]
				logout current_admin
			end
			flash[:error] = "Sorry, you are automatically logged out because of malicious activities"
		end
	end
	
	def require_lecturer_login
		if !session[:student_id]
			if session[:student_id]
				logout current_student
			end
			if session[:admin_id]
				logout current_admin
			end
			flash[:error] = "Sorry, you are automatically logged out because of malicious activities"
		end
	end
end
