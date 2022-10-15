class Course < ApplicationRecord
  has_many :course_aliases, :dependent => :destroy
  has_many :calendars, :through => :course_aliases
  has_and_belongs_to_many :subjects
end
