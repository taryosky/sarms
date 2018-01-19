class Student < ApplicationRecord

	has_one :student_othername, dependent: :destroy
	
	has_many :registrations, dependent: :destroy
	has_many :courses, through: :registrations

	has_many :assignment_submissions, dependent: :destroy

	enum sex: [:male, :female]
	VALID_STRING_ONLY = /\A[A-Za-z]/
	validates :fname, presence: true, length: {minimum: 3}, format: {with: VALID_STRING_ONLY}
	validates :sname, presence: true, length: {minimum: 3}, format: {with: VALID_STRING_ONLY}	
	validates :matno, presence: true, uniqueness:{case_sensitive: false}

			VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]{2,}+\z/i
			
			# validates :fname, presence: true, length: {minimum: 3}, format: {with: VALID_STRING_ONLY}
			# validates :sname, presence: true, length: {minimum: 3}, format: {with: VALID_STRING_ONLY}	
			# validates :email, presence: true, length: {maximum: 255}, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false}
			# validates :sex, presence: true
			# validates :state_of_origin, presence: true, format: {with: VALID_STRING_ONLY}
			# validates :nationality, presence: true, format: {with: VALID_STRING_ONLY}
			# validates :religion, presence: true, format: {with: VALID_STRING_ONLY}

	def user_type
		return 0
	end

	def gen_login_password
		user=self
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
	end

end