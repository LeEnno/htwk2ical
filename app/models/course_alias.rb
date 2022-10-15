class CourseAlias < ApplicationRecord
  belongs_to :course
  belongs_to :calendar
end
