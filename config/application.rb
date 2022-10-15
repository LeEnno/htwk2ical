require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Htwk2ical
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de

    # get around "Tried to load unspecified class" when
    # serializing cached schedules
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::Duration, Symbol]

    # custom config
    # --------------------------------------------------------------------------

    # maintenanace mode
    config.is_maintenance = false

    # calendars created before this date will be told to update
    config.latest_valid_date = Time.new(2022, 10, 9, 17, 45)

    # date and week when semester started
    config.start_date = Time.new(2022, 10, 17)
    config.start_week = 42

    # path to XML files for subjects and courses
    config.all_subjects_xml_url = 'https://stundenplan.htwk-leipzig.de/stundenplan/xml/public/semgrp_ws.xml'
    config.all_courses_xml_url  = 'https://stundenplan.htwk-leipzig.de/stundenplan/xml/public/modul_ws.xml'

    # ID of XML node in 'all_courses_xml_url' that contains all studium generale
    # modules
    config.studium_generale_fakultaet_id = '%23SPLUS0AC5B0'

    # base path for single schedule per subject and studium generale
    config.single_subjects_html_url   = 'https://stundenplan.htwk-leipzig.de/ws/Berichte/Text-Listen;Studenten-Sets;name;###SLUG###?template=UNEinzelGru&weeks=35-61'
    config.studium_generales_html_url = 'https://stundenplan.htwk-leipzig.de/ws/Berichte/Text-Listen;Module;id;###SLUG###?template=UNEinzelLV&weeks=35-61'
  end
end
