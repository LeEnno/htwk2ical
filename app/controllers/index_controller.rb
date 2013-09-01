class IndexController < ApplicationController
  def index
    @landing_page = true
  end


  def faq
    @faq_page = true
  end


  def contact
    @contact_page = true
  end


  def imprint
    @imprint_page = true
  end
end
