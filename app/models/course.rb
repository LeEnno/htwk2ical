class Course < ActiveRecord::Base
  attr_accessible :title

  has_many :course_aliases, :dependent => :destroy
  has_many :calendars, :through => :course_aliases
  has_and_belongs_to_many :subjects

  # TODO should throw error
  def self.new_calendar_courses(course_ids)
    courses_to_add = []

    course_ids.each do |course_id|
      course = Course.find(course_id)
      if course.nil?
        logger.info("Falsche Course-ID: #{course_id}")
        next
      end
      courses_to_add << course
    end

    courses_to_add
  end
end
