# encoding: utf-8
class CalendarController < ApplicationController
  def get
    calendar = Calendar.find_by_secret(params[:calendar_secret])
    if calendar.nil?
      render :status => 404
      return
    end

    calendar.update_attribute(:fetched_at, Time.now)

    @events = calendar.events
    @now    = Time.now.strftime("%Y%m%d\T%H%M%S")
    @secret = params[:calendar_secret]

    headers['Content-Disposition'] = "attachment; filename=\"HTWK2iCal\""
  end


  def choose_subjects
    @add_calendar_page = true
    @subject_titles    = params[:'subject-titles']
  end


  def choose_courses
    @add_calendar_page = true
    subject_titles     = params[:'subject-titles']
    return _redirect_to_calendar_path if subject_titles.nil?

    require 'uri'
    subject_titles_param_arr = []
    @subjects                = []
    subject_titles.each do |subject_title|
      subject = Subject.find_by_title(subject_title)
      next if subject.nil?
      courses = subject.courses.select(%w(courses.id title)).order(:title)
      @subjects << {:id => subject.id, :title => subject.title, :courses => courses}
      subject_titles_param_arr << "subject-titles[]=#{URI.encode(subject_title)}"
    end

    return _redirect_to_calendar_path if @subjects.empty?

    @choose_subjects_link = calendar_path + '?' + subject_titles_param_arr * '&'
  end


  def get_link
    if params[:subject_ids].nil? || params[:subject_ids].blank?
      return _redirect_to_calendar_path

    elsif params[:course_ids].nil? || params[:course_ids].blank?
      flash[:notice] = 'Bitte wähle Module, die dein Kalender beinhalten soll!'
      return redirect_to(
        url_for :action => 'choose_courses',
        :test => 1,
        :'subject-titles' => params[:subject_ids].collect {|i| Subject.find(i).title}
      ).gsub(/:3000:3000/, ':3000') # gsub for doubled port fix
    end

    @add_calendar_page = true
    #begin
      @secret = Calendar.new(
        params[:subject_ids],
        params[:course_ids],
        params[:course_aliases]
      ).secret
    #rescue Exception => e
    #  logger.info(e.message)
    #  logger.info(e.backtrace)
    #  @canceled = true
    #end
  end


  def get_subjects
    render :json => File.read(Rails.root.join('public', 'subjects.json'))
  end


  private
  def _redirect_to_calendar_path
    redirect_to calendar_path, :notice => 'Bitte wähle einen gültigen Studiengang!'
  end
end