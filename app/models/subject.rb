# encoding: utf-8
include ActionView::Helpers::SanitizeHelper

class Subject < ActiveRecord::Base
  attr_accessible :cached_schedule, :extended_title, :title
  serialize :cached_schedule

  has_and_belongs_to_many :courses
  has_and_belongs_to_many :calendars


  # Updates the cached subjects and courses.
  #
  # Updates available subjects in database. For each of them we fetch the HTML
  # of the schedule and convert it to an array containing hashes of courses.
  # Finally this array will be stored in the database for building the
  # calendars.
  #
  #  In between we have to make sure all courses are stored in the database as
  # well. So once we get the hashified array of courses per day in a week, we
  # switch all course names with course IDs. This way we ensure less redundancy
  # and therefore less database space.
  def self.rebuild_cache
    all_subjects = _update_available_subjects
    all_subjects.each do |single_subject|
      #next unless ['12BI/GSW-M', '12BI/HBB-M'].include?(single_subject.title)
      #single_subject = Subject.find_by_title("12MI-M")
      puts single_subject.title
      schedule_html = _fetch_schedule(single_subject.title)
      if schedule_html.match(/503 Service Temporarily Unavailable/)
        puts "aborted because of 503 error"
        return
      end
      schedule_arr = _make_array(schedule_html, single_subject.id) # TODO into courses?

      # cache extracted
      Subject.find(single_subject.id).update_attributes(
        :cached_schedule => schedule_arr
      )
    end

    puts "done"
  end

  private

  # Fetch all subjects and write the new ones into the database. Besides we will
  # write all subjects into the JSON-view for autocompleting the input field on
  # our index page for entering the subject. Returns an array containing IDs and
  # titles for each subject.
  def self._update_available_subjects
    subjects_arr = []

    require "rexml/document"
    url = Htwk2ical::Application.config.all_subjects_xml_url
    xml = _fetch_contents_from_url(url)
    doc = REXML::Document.new xml

    doc.elements.each('studium/fakultaet/studiengang/semgrp') do |element|
      title          = element.attributes['name']
      category       = element.parent.attributes['name']
      subject        = Subject.find_or_create_by_title(title)
      subjects_arr   << _make_autocomplete_hash(title, category, subject.id)
      
      if subject.extended_title.nil?
        subject.extended_title = subjects_arr.last[:label]
        subject.save
      end
    end

    json_file = Rails.root.join('public', 'subjects.json')
    File.open(json_file, 'w') {|f| f.write(subjects_arr.to_json) }

    Subject.select([:id, :title])
  end


  # Get the HTML-schedule for a certain subject.
  #
  # The 'subject_title' parameter must be a title as stored in courses table,
  # i.e. 09FL-B.
  def self._fetch_schedule(subject_title)
    require 'uri'
    url = Htwk2ical::Application.config.single_subjects_html_url \
            .gsub(/###SUBJECT_TITLE###/, URI.encode(subject_title))

    _fetch_contents_from_url(url).force_encoding("ISO-8859-1").encode("UTF-8")
  end


  # Strips unnecessary markup and returns an array with course hashes per day.
  #
  # See 'make_course_hashes' for more information.
  def self._make_array(html, subject_id)
    html = html
      .gsub(/<!DOCTYPE.*<p><span >Mo/m, "<p><span >Mo")        # delete pre-table
      .gsub(/<table   border.*<\/html>/m, "")                  # delete post-table

    html = strip_tags(html).strip                              # strip tags
      .gsub(/&nbsp;/, "LEER")                                  # convert spaces
      .gsub(/So$/, "So\r\n\r\n\r\n\r\n")                      # handle "special" sundays
      .gsub(/(Mo|Di|Mi|Do|Fr|Sa|So)(\r\n){4}/, "###TRENN###")  # mark day separations
      .gsub(/(\r\n){4}/, "")                                  # delete 4x EOL
      .gsub(/Planungswochen[^0-9]+am:/m, "")                  # delete table head

    courses_splitted_by_days = html.split("###TRENN###")
    _make_course_hashes(courses_splitted_by_days, subject_id)
  end


  # Extracts information for every course and stores it in a hash.
  #
  # 'courses_splitted_by_days' is an array containing reduced markup for each
  # day of the week. The structure of 'courses_splitted_by_days' is as follows:
  #
  #  courses_splitted_by_days = [
  #   string for courses on monday (with whitespace as dividers),
  #   string for courses on tuesday (with whitespace as dividers),
  #   ...
  # ]
  #
  # We walk through every day and find single courses. We extract the relevant
  # information (start, end, location, etc.) and store it in a hash. All hashes
  # will be stored in a day-specific array. This array is added to an array
  # called 'converted_courses' which will be returned. The structure of
  # 'converted_courses' is as follows:
  #
  #  converted_courses = [
  #   array for all courses on monday
  #     some monday course hash,
  #     another monday course hash,
  #     ...
  #   array for all courses on monday
  #     some tuesday course hash,
  #     another tuesday course hash,
  #     ...
  #   ...
  # ]
  def self._make_course_hashes(courses_splitted_by_days, subject_id)
    converted_courses = []
    subject           = Subject.find(subject_id)

    courses_splitted_by_days.each do |day_courses_str|
      next if day_courses_str.empty?
      if day_courses_str.match(/^\r\n(So)?$/) # TODO "(So)?" necessary?
        converted_courses << []
        next
      end

      day_courses_arr_with_strings = day_courses_str.split("\r\n\r\n\r\n")
      day_courses_arr_with_hashes = []

      day_courses_arr_with_strings.each do |course_str|
        next if course_str.empty?

        course_arr = course_str.split("\r\n")
        next if course_arr[4] == 'LEER'
        
        course = Course.find_or_create_by_title(course_arr[4].strip)
        course_hash = {
          :weeks    => _make_week_array(course_arr[0]),
          :start    => _make_time(course_arr[1]),
          :end      => _make_time(course_arr[2]),
          :location => _get_value_or_empty_string(course_arr[3]),
          :id       => course.id,
          :type     => course_arr[5],
          :lecturer => _get_value_or_empty_string(course_arr[6]),
          :notes    => _get_value_or_empty_string(course_arr[7])}

        # connect course and subject, if not done already
        subject.courses << course unless subject.courses.include?(course)

        day_courses_arr_with_hashes << course_hash
      end # day_courses_arr.each

      converted_courses << day_courses_arr_with_hashes
    end # all_courses_arr.each

    subject.save
    converted_courses
  end


  # Replaces unnecessary information in title and category. Returns a hash
  # formatted according to conventions of jQuery Autocomplete Plugin.
  def self._make_autocomplete_hash(title, category, id)
    category = category.gsub(/( \(.*\))* \((Bachelor|Master|Diplom)?.*\)/, ' (\2)')
    label    = title.gsub(/ \(.*\)/, "") + " – " + category
    
    {:label => label, :id => id}
  end


  # Replaces empty columns with empty string.
  def self._get_value_or_empty_string(val)
    return '' if val == "LEER"
    val
  end

  # Converts "12, 14, 17-20" into array of week integers
  def self._make_week_array(weeks_str)
    weeks_arr = []
    weeks_str.split(",").each do |week|
      week.match(/(\d{2})(-(\d{2}))?/) do |match|
        # if we have no "-" in there: add one week
        if match[2].nil?
          weeks_arr << match[1].to_i
          # if we have a "-" in there: add all weeks
        else
          weeks_arr += (match[1].to_i..match[3].to_i).to_a
        end
      end
    end
    weeks_arr
  end

  # Converts "8:30" and "12:00" to time classes
  def self._make_time(time_str)
    time_str.match(/(\d{1,2}):(\d{2})/) do |match|
      return match[1].to_i.hours + match[2].to_i.minutes
    end
  end

  # Helper for getting URL contents.
  def self._fetch_contents_from_url(url)
    require 'net/http'
    Net::HTTP.get(URI.parse(url))
  end
end
