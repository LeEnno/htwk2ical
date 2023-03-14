class IndexController < ApplicationController
  def index
    config = Htwk2ical::Application.config
    if config.is_maintenance
      if config.show_donation_call
        _set_donate_vars
        @show_donation_call = true
      end
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
    @amount_max      = 80
    @amount_percent  = (100 * @amount_current / @amount_max).round(2)
    @amount_heroku   = 14
  end
end
