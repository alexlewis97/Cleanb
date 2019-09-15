class Employee < ApplicationRecord
	has_many :work_day
	validates :name, presence: true
end
