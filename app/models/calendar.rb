# encoding: UTF-8
# TODO must have secret
class Calendar < ActiveRecord::Base
  attr_accessible :secret

  has_many :course_aliases, :dependent => :destroy
  has_many :courses, :through => :course_aliases,
           :select => "course_aliases.custom_name as custom_name, courses.*"
  has_and_belongs_to_many :subjects

  before_create :_generate_secret

  # makes sure only valid subjects and courses are added
  def initialize(subject_ids, course_ids)
    super()

    # validate subjects, add courses and create alias relationships
    subject_ids.each do |subject_id|
      subject = Subject.find(subject_id)
      raise ArgumentError, "invalid subject-ID" if subject.nil?

      subjects << subject
      self.courses = Course.new_calendar_courses(course_ids)
    end
  end

  # Adds transmitted aliases for selected courses. Throws error if transmitted
  # course-ID is invalid.
  def add_aliases(course_aliases_hash)
    course_aliases_hash.each do |course_id, custom_name|
      course = courses.find(course_id)
      next if course.nil?

      # add alias if different from actual course-title
      if course_aliases_hash[course_id] != course.title
        course_aliases.find_by_course_id(course_id).update_attribute(:custom_name, custom_name)
      end
    end
  end

  # TODO comment
  def events
    secret      = self.secret
    time_format = "%Y%m%dT%H%M%S"

    # don't fetch events for outdated calendars
    if created_at < Htwk2ical::Application.config.latest_valid_date
      now         = Time.new
      event_start = now.strftime(time_format)
      event_end   = (now + 2.hours).strftime(time_format)
      
      return [{
        :summary     => 'Kalender aktualisieren',
        :description => 'Dein Kalender ist nicht mehr gültig. Bitte besuche http://www.htwk-stundenplan.de, um einen neuen zu erstellen.',
        :start       => event_start,
        :end         => event_end,
        :uid         => "#{secret}_#{event_start}-#{event_end}_deprecated"
      }]
    end

    # date when semester started
    time_ref = Htwk2ical::Application.config.start_date
    week_ref = Htwk2ical::Application.config.start_week

    courses_cache = _get_course_titles_hash
    events        = []

    self.subjects.pluck(:cached_schedule).each do |cached_schedule|
      cached_schedule.each_with_index do |day_courses, day_counter|
        day_courses.each do |course|
          course_title = courses_cache[course[:id].to_s]
          next if course_title.nil?

          course[:weeks].each do |week|
            day_start   = time_ref + (week - week_ref).weeks + day_counter.days
            description = []
            description << course[:lecturer] if course[:lecturer].present?
            description << course[:notes]    if course[:notes].present?
            event_start = (day_start + course[:start]).strftime(time_format)
            event_end   = (day_start + course[:end]).strftime(time_format)

            events << {
              :location    => course[:location],
              :summary     => course_title + " (#{course[:type]})",
              :description => description.join(', '),
              :start       => event_start,
              :end         => event_end,
              :uid         => "#{secret}_#{event_start}-#{event_end}_#{course_title.parameterize}"
            }
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
      courses_cache[course.id.to_s] = title
    end

    courses_cache
  end
end
