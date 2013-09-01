# encoding: UTF-8
# TODO must have secret
class Calendar < ActiveRecord::Base
  attr_accessible :secret

  has_many :course_aliases, :dependent => :destroy
  has_many :courses, :through => :course_aliases,
           :select => "course_aliases.custom_name as custom_name, courses.*"
  has_and_belongs_to_many :subjects

  before_create :_generate_secret

  # TODO comment
  def initialize(subject_ids, course_ids, course_aliases_arr)
    super()
    # TODO enable courses from multiple subjects (subject_ids.each)
    subject_ids.each do |subject_id|
      subject = Subject.find(subject_id)
      raise ArgumentError, "invalid subject-ID" if subject.nil?

      subjects << subject
      self.courses = Course.new_calendar_courses(course_ids) # TODO how to omit self?
      save_and_add_aliases(course_aliases_arr, course_ids)
    end
  end

  # Saves changes and adds transmitted aliases for selected courses. Throws
  # error if transmitted course-ID is invalid.
  def save_and_add_aliases(course_aliases_arr, course_ids)
    save

    # clean unused aliases
    course_aliases_arr.reject! { |key, val| !course_ids.include?(key) }

    course_aliases_arr.each do |course_id, custom_name|
      course = courses.find(course_id)
      next if course.nil?

      # add alias if different from actual course-title
      if course_aliases_arr[course_id] != course.title
        course_aliases.find_by_course_id(course_id).update_attribute(:custom_name, custom_name)
      end
    end
  end

  # TODO comment
  def events
    secret = self.secret
    time_format = "%Y%m%dT%H%M%S"
    courses_cache = _get_course_titles_hash
    events = []

    self.subjects.pluck(:cached_schedule).each do |cached_schedule|
      day_counter = -1 # for starting at 0
      # date when semester started
      time_ref = Time.new(2013, 3, 11)
      week_ref = 11

      cached_schedule.each do |day_courses|
        day_counter += 1
        day_courses.each do |course|
          course_title = courses_cache[course[:id].to_s]
          next if course_title.nil?

          course[:weeks].each do |week|
            day_start = time_ref + (week - week_ref).weeks + day_counter.days
            event = {}
            event[:location]    = course[:location]
            event[:summary]     = course_title + " (#{course[:type]})"
            event[:description] = course[:lecturer]
            event[:description]+= ", #{course[:notes]}" unless course[:notes].empty?
            event[:start] = (day_start + course[:start]).strftime(time_format)
            event[:end]   = (day_start + course[:end]).strftime(time_format)
            event[:uid]   = "#{secret}_#{event[:start]}-#{event[:end]}_#{course_title.parameterize}"
            events << event
          end
        end
      end
    end

    events
  end


  private

  # Generates a new secret by creating an MD5-hash of the current UNIX-time (ms
  # since 01.01.1970) with a random number appended. By checking whether the
  # generated secret exists we make sure it stays unique.
  def _generate_secret
    require 'digest/md5'
    begin
      self.secret = Digest::MD5.hexdigest((Time.now.to_i + rand(1..99)).to_s).to_s[0..7]
    end while Calendar.find_by_secret(self.secret)
  end

  # Extracts all courses' titles and IDs into a hash. Values can then be
  # accessed by courses["4"], where "4" is the course's ID.
  def _get_course_titles_hash
    courses_cache = {}

    courses.each do |course|
      title = course.custom_name || course.title
      id_str = course.id.to_s
      courses_cache[id_str] = title
    end

    courses_cache
  end
end
