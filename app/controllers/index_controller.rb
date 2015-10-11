class IndexController < ApplicationController
  def index
    if Htwk2ical::Application.config.is_maintenance
      render('maintenance', :layout => 'maintenance') && return
    end
    @landing_page = true
  end


  def donate
    @donate_page = true

    @amount_current  = SubjectCache.find_by_key('donate_amount').value.to_f
    @amount_max      = 50
    @amount_percent  = (100 * @amount_current / @amount_max).round(2)
    @amount_heroku   = 9
  end


  def faq
    @faq_page = true
  end


  def contact
    @contact_page = true
  end


  def imprint
    render :layout => 'imprint'
  end
end
