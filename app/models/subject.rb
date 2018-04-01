# encoding: utf-8
include ActionView::Helpers::SanitizeHelper

class Subject < ActiveRecord::Base
  attr_accessible :cached_schedule, :extended_title, :title
  serialize :cached_schedule

  has_and_belongs_to_many :courses
  has_and_belongs_to_many :calendars


  # whether current subject is studium generale or regular subject
  def studium_generale?
    extended_title.nil?
  end


  # Updates the cached subjects and courses.
  #
  # Updates available subjects in database. For each of them we fetch the HTML
  # of the schedule and convert it to an array containing hashes of courses.
  # Finally this array will be stored in the database for building the
  # calendars.
  #
  # In between we have to make sure all courses are stored in the database as
  # well. So once we get the hashified array of courses per day in a week, we
  # switch all course names with course IDs. This way we ensure less redundancy
  # and therefore less database space.
  def self.rebuild_cache
    print 'updating subjects...'

    @sg_courses = {}
    _update_available_subjects

    puts 'done', 'updating cached_schedules...'
    
    skipped   = []
    not_found = []

    Subject.select([:id, :title, :slug, :extended_title]).each_with_index do |s, i|
      puts ordered_title = (i+1).to_s + ' ' + s.title
      
      # ugly fix: skip deprecated subject '12CW-M (nicht besetzt)'
      if s.title == '12CW-M (nicht besetzt)'
        skipped << ordered_title
        puts 'skipped'
        next
      end

      schedule_html = _fetch_schedule(s.slug || s.title, s.studium_generale?)

      # catch 503 and 400 errors
      if schedule_html.match(/503 Service Temporarily Unavailable/)
        puts 'aborted because of 503 error'
        return
      elsif schedule_html.match(/400  Falsche Anfrage/)
        not_found << ordered_title + " (#{s.id})"
        puts 'not found'
        next
      end

      schedule_arr = _make_array(schedule_html, s.id) # TODO into courses?

      # cache extracted
      Subject.find(s.id).update_attributes(
        :cached_schedule => schedule_arr
      )
    end

    puts 'updating cached_schedules done'
    print 'saving json file for SG...'
    
    # TODO DRY
    # TODO constantify
    SubjectCache
      .find_or_create_by_key('studium_generales')
      .update_attributes(:value => @sg_courses.values.to_json)

    puts 'done'
    puts 'skipped subjects:', skipped if skipped.count > 0
    puts 'subjects not found:', not_found if not_found.count > 0
  end


  # TODO update comments
  #
  # Fetch all subjects and write the new ones into the database. Besides we will
  # write all subjects into the JSON-view for autocompleting the input field on
  # our index page for entering the subject. Returns an array containing IDs and
  # titles for each subject.
  def self._update_available_subjects
    require 'rexml/document'

    [
      {
        :is_sg_mode => false,
        :url        => Htwk2ical::Application.config.all_subjects_xml_url,
        :xpath      => 'studium/fakultaet/studiengang/semgrp'
      }, {
        :is_sg_mode => true,
        :url        => Htwk2ical::Application.config.all_courses_xml_url,
        :xpath      => 'studium/fakultaet[@id="' +
                       Htwk2ical::Application.config.studium_generale_fakultaet_id +
                       '"]/modul[starts-with(@name, "Stud. gen.")]'
      }
    ].each do |mode_hash|
      subjects_arr = []
      xml          = _fetch_contents_from_url(mode_hash[:url])
      doc          = REXML::Document.new xml

      doc.elements.each(mode_hash[:xpath]) do |element|
        title = element.attributes['name']
        title.gsub!(/Stud. gen. +/, '') if mode_hash[:is_sg_mode]
        
        category = mode_hash[:is_sg_mode] ? nil : element.parent.attributes['name']
        subject  = Subject.find_or_create_by_title(title)
        subjects_arr << _make_autocomplete_hash(title, category, subject.id)

        if mode_hash[:is_sg_mode] && subject.slug.nil?
          subject.slug = element.attributes['id'].gsub(/%23/, '#')
          subject.save        
        elsif !mode_hash[:is_sg_mode] && subject.extended_title.nil?
          subject.extended_title = subjects_arr.last[:label]
          subject.save
        end

        @sg_courses[subject.id] = {} if mode_hash[:is_sg_mode]
      end

      # TODO DRY
      # TODO constantify
      if !mode_hash[:is_sg_mode]
        SubjectCache.find_or_create_by_key('subjects').update_attributes(:value => subjects_arr.to_json)
      end
    end
  end


  # Get the HTML-schedule for a certain subject.
  #
  # The 'subject_title' parameter must be a title as stored in courses table,
  # i.e. '09FL-B'.
  def self._fetch_schedule(slug, isStudiumGenerale = false)
    require 'uri'
    url = isStudiumGenerale \
      ? Htwk2ical::Application.config.studium_generales_html_url \
      : Htwk2ical::Application.config.single_subjects_html_url
    
    url = url.gsub(/###SLUG###/, URI.encode(slug))

    _fetch_contents_from_url(url).force_encoding("ISO-8859-1").encode("UTF-8")
  end


  # Strips unnecessary markup and returns an array with course hashes per day.
  #
  # See 'make_course_hashes' for more information.
  def self._make_array(html, subject_id)
    html = html
      .gsub(/<!DOCTYPE.*<p><span class='labelone'>Mo/m, "<p><span class='labelone'>Mo") # delete pre-table
      .gsub(/\r\n<table class='footer-border-args.*html>/m, '') # delete post-table
  
    html = strip_tags(html).strip                              # strip tags
      .gsub(/&nbsp;/, 'LEER')                                  # convert spaces
      .gsub(/So$/, "So\r\n\r\n\r\n\r\n")                       # handle "special" sundays
      .gsub(/(Mo|Di|Mi|Do|Fr|Sa|So)(\r\n){4}/, '###TRENN###')  # mark day separations
      .gsub(/(\r\n){4}/, '')                                   # delete 4x EOL
      .gsub(/Planungswochen[^0-9]+am:/m, '')                   # delete table head

    courses_splitted_by_days = html.split('###TRENN###')
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
    is_sg             = subject.studium_generale?

    if is_sg

      # studium generale modules follow this pattern: name/lecturer[/lecturer]
      matches = subject.title.match(/([^\/]+)\/(.+)/)
      
      # ugly fix for 'Mediendramaturgie und Videoproduktion 2 (Jürgen Kästner)'
      matches = subject.title.match(/([^(]+)\((.+)\)/) if matches.nil?

      # ugly fix for 'Meeting'
      matches = [nil, subject.title, ''] if matches.nil?

      sg_title    = matches[1]
      sg_lecturer = matches[2]
      sg_course   = Course.find_or_create_by_title(sg_title.strip)
      subject.courses << sg_course
      if @sg_courses.has_key?(subject.id) && @sg_courses[subject.id].empty?
        # TODO DRY (_make_autocomplete_hash)
        @sg_courses[subject.id] = {
          :label      => sg_title,
          :id         => sg_course.id,
          :subject_id => subject.id
        }
      end
    end

    courses_splitted_by_days.each_with_index do |day_courses_str|
      next if day_courses_str.empty?
      if day_courses_str.match(/^\r\n(So)?$/) # TODO "(So)?" necessary?
        converted_courses << []
        next
      end

      day_courses_arr_with_hashes = []

      day_courses_str.split("\r\n\r\n\r\n").each do |course_str|
        next if course_str.empty?

        course_arr   = course_str.split("\r\n")
        course_title = course_arr[4]
        next if course_title == 'LEER'
        
        course = sg_course || Course.find_or_create_by_title(course_title.strip)
        course_hash = {
          :weeks    => _make_week_array(course_arr[0]),
          :start    => _make_time(course_arr[1]),
          :end      => _make_time(course_arr[2]),
          :location => _get_value_or_empty_string(course_arr[3]),
          :id       => course.id,
          :type     => course_arr[is_sg ? 4 : 5],
          :lecturer => _get_value_or_empty_string(course_arr[is_sg ? 5 : 6]),
          :notes    => _get_value_or_empty_string(course_arr[7])}
        
        if is_sg
          course_hash[:lecturer] = sg_lecturer if course_hash[:lecturer].empty?
        end

        # connect course and subject, if not done already
        subject.courses << course unless is_sg || subject.courses.include?(course)

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
    if category.present?
      category.gsub!(/( \(.*\))* \((Bachelor|Master|Diplom)?.*\)/, ' (\2)')
    end

    label    = title.gsub(/ \((?!VZ|TZ).*\)/, '')
    label   += " – #{category}" if category.present?

    # TODO DRY
    {:label => label, :id => id}
  end


  # Replaces empty columns with empty string.
  def self._get_value_or_empty_string(val)
    val == 'LEER' ? '' : val
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
