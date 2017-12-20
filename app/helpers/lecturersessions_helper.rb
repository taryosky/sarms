module LecturersessionsHelper
	
	def login_lect(lecturer)
		if session[:student_id]
			session.delete(:student_id)
		end
		if session[:admin_id]
			session.delete(:admin_id)
		end
		session[:staff_id] = lecturer.id
	end

	def current_lecturer
		@current_lecturer ||= Lecturer.find_by(id: session[:staff_id])
	end

	def lect_logged_in?
		!current_lecturer.nil?
	end

	def logout_lect
		session.delete(:staff_id)
		@current_lecturer = nil
	end

end