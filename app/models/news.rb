class News < ApplicationRecord
	has_one :news_image, dependent: :destroy
	
	validates :title, presence: true
	validates :content, presence: true
end
