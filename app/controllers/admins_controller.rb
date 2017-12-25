class AdminsController < ApplicationController

	before_action :require_login 	#require_login method is defined in application_helper.rb
	before_action :require_admin_login, only:[:create, :update, :delete]		#require_admin_login is definded in login_sessions_helper.rb


  def new
  end

  def create
  	@admin = Admin.new(argument)
  	if @admin.save
      password = params[:admin][:password].strip!
      admin_password = gen_login_details(@admin.id, @admin.name, password)
  		render plain: 'registered'+admin_password
  	end
  end

  def edit
  end

  private
        def argument
            params.require(:admin).permit(:name)
        end
        def gen_login_details(admin_table_id, admin_id, password)
            user_id = admin_id
            user_type = 2
            user_activation_status = 1
            @user_password =  password
            login_detail = LoginDetail.create(user_id: admin_table_id, user_name: user_id, user_type: user_type, activation: user_activation_status, password: @user_password)
            return @user_password
        end
end