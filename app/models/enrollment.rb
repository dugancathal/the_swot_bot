class Enrollment < ActiveRecord::Base
  attr_accessible :student_id, :course_id, :current_grade
	validates :student_id, :presence => true
	validates :course_id, :presence => true
	validates :student_id, :uniqueness => { :scope => :course_id }
	validate  :period_uniqueness, :on => :create

	belongs_to :course
	belongs_to :student
	has_many 	 :student_actions

	def period_uniqueness
		return unless self.course_id
		period = course.period
		student_courses.each do |course|
			if period == course.period
				errors.add(:course_id, "Students can only be enrolled in one course per period")
			end
		end
	end

	def student_courses
		student.courses
	end

	def letter_grade
		case current_grade
		when 0.90...Float::INFINITY
			return "A"
		when 0.80...0.90
			return "B"
		when 0.70...0.80
			return "C"
		when 0.60...0.70
			return "D"
		when 0...0.60
			return "F"
		else
			return ""
		end
	end

end
