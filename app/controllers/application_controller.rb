class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_locale

  private

  def set_locale
    # don't set locale for calender getters and autocomplete source actions
    unless params[:controller] == 'calendar' \
      && %w(get download get_subjects get_studium_generales).include?(params[:action])

      # if no locale is set, extract from HTTP header and redirect
      unless params[:locale]
        # TODO better way?
        return redirect_to '/' + extract_locale + request.env['PATH_INFO']
      end

      I18n.locale = params[:locale]
      Rails.application.routes.default_url_options[:locale]= I18n.locale
    end
  end

  def extract_locale
    default = I18n.default_locale.to_s
    accept  = request.env['HTTP_ACCEPT_LANGUAGE']
    return default if accept.nil?

    locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    locale = I18n.default_locale.to_s unless %w(de en).include?(locale)
    locale
  end
end
