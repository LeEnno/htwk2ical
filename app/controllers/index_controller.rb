class IndexController < ApplicationController
  def index
    if Htwk2ical::Application.config.is_maintenance
      render('maintenance', :layout => 'maintenance') && return
    end
    @landing_page = true
  end


  def donate
    @donate_page = true
    _set_donate_vars
  end


  def faq
    @faq_page = true
  end


  def contact
    @contact_page = true
  end


  private


  def _set_donate_vars
    @amount_current  = SubjectCache.find_by(key: 'donate_amount').value.to_f
    @amount_max      = 50
    @amount_percent  = (100 * @amount_current / @amount_max).round(2)
    @amount_heroku   = 9
  end
end
