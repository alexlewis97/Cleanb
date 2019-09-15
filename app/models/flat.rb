class Flat < ApplicationRecord
	has_many :task
	has_many :reservation
	validates :address, presence: true, uniqueness: true
	
end