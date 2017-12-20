class Lecturer < ApplicationRecord

	has_many :course_allocations
	has_many :courses, through: :course_allocations
	has_many :assignments
	has_one :lecturer_othername, dependent: :destroy

	VALID_STRING_ONLY = /\A[A-Za-z]/i

	enum sex: [:male, :female]
	
	validates :staff_id, presence: true
	validates :fname, presence: true, length: {minimum: 3}, format: {with: VALID_STRING_ONLY}
	validates :sname, presence: true, length: {minimum: 3}, format: {with: VALID_STRING_ONLY}
	
	before_save{
		if !self.new_record?
			VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
		end
	}
	def user_type
		return 1
	end
end
