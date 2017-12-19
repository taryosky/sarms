class AdminsessionsController < ApplicationController

	before_action :require_login 			#require_login method is defined in login_sessions_helper.rb
	#before_action :require_admin_login 		#require_admin_login is definded in login_sessions_helper.rb
	
	def index
	end

	def new
		
	end

	def create
		admin = Admin.find_by(name: params[:adminsession][:name])
		if admin 
			login_admin(admin)
			redirect_to admin_index_path
		else
			flash[:error] = "Username or Password is not incorrect"
			redirect_to admin_login_path
		end
	end

	def destroy
		logout_admin
		redirect_to user_login_path
	end
end