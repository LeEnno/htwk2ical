class CourseAlias < ActiveRecord::Base
	attr_accessible :course_id, :calendar_id, :custom_name

	belongs_to :course
	belongs_to :calendar
end
