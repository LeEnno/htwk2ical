# encoding: utf-8
class CalendarController < ApplicationController

  SUBJECT_ID_DIVIDER = '-'


  def get
    calendar = Calendar.find_by(secret: params[:calendar_secret])
    if calendar.nil?
      head :not_found
      return
    end

    begin
      calendar.update_attribute(:fetched_at, Time.now)
    rescue PG::ReadOnlySqlTransaction
      # if heroku is in temporary maintenance mode: ignore updating fetched_at
      # and instead make sure to return calendar data
    end

    @events = calendar.events
    @now    = Time.now.strftime("%Y%m%d\T%H%M%S")
    @secret = params[:calendar_secret]

    headers['Content-Disposition'] = "attachment; filename=\"HTWK2iCal.ics\""
  end


  def choose_subjects
    @add_calendar_page = true
    subject_ids = params[:subject_ids]
    unless subject_ids.nil?
      subject_ids = subject_ids.split(SUBJECT_ID_DIVIDER).keep_if { |id| Subject.exists?(id) }
      @subjects = Subject.find(subject_ids)
    end
  end


  def choose_courses
    @add_calendar_page = true
    subject_ids        = params[:subject_ids]
    return _redirect_to_calendar_path if subject_ids.nil?

    subject_ids_param_arr = []
    @subjects             = []
    
    subject_ids.split(SUBJECT_ID_DIVIDER).each do |subject_id|
      subject = Subject.find(subject_id)
      next unless Subject.exists?(subject_id)
      
      courses = subject.courses.select(%w(courses.id title)).order(:title)
      @subjects << {:id => subject.id, :title => subject.title, :courses => courses}
      subject_ids_param_arr << subject.id
    end

    return _redirect_to_calendar_path if @subjects.empty?

    @choose_subjects_link = calendar_path(:subject_ids => subject_ids_param_arr * SUBJECT_ID_DIVIDER)
  end


  def get_link
    if params[:subject_ids].blank?
      return _redirect_to_calendar_path

    elsif params[:course_ids].blank? || params[:course_aliases].blank?
      flash[:notice] = 'Bitte wähle Module, die dein Kalender beinhalten soll!'
      return redirect_to url_for(
          :action => 'choose_courses',
          :'subject-titles' => params[:subject_ids].collect {|i| Subject.find(i).title}
      )
    end

    @add_calendar_page = true

    calendar = Calendar.new(subjects: Subject.find(params[:subject_ids]), courses: Course.find(params[:course_ids]))
    calendar.save
    aliases = params[:course_aliases].reject { |key, val| !params[:course_ids].include?(key) }
    calendar.add_aliases(aliases)
    @secret = calendar.secret
  end


  def get_subjects
    render :json => SubjectCache.find_by(key: 'subjects').value
  end

  def get_studium_generales
    render :json => SubjectCache.find_by(key: 'studium_generales').value
  end


  private
  def _redirect_to_calendar_path
    redirect_to calendar_path, :notice => 'Bitte wähle einen gültigen Studiengang!'
  end
end