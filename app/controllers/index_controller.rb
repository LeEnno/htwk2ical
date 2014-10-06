class IndexController < ApplicationController
  def index
    if Htwk2ical::Application.config.is_maintenance
      render('maintenance', :layout => 'maintenance') && return
    end
    @landing_page = true
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
