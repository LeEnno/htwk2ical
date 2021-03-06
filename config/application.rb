require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Htwk2ical
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # For faster asset precompiles, heroku needs this to be false,
    # see http://guides.rubyonrails.org/asset_pipeline.html#precompiling-assets
    config.assets.initialize_on_precompile = true

    # config.action_controller.default_url_options = {:host => 'localhost:3000'}

    # custom config
    # --------------------------------------------------------------------------

    # maintenanace mode
    config.is_maintenance = false

    # calendars created before this date will be told to update
    config.latest_valid_date = Time.new(2021, 3, 22, 20)

    # date and week when semester started
    config.start_date = Time.new(2021, 4, 5)
    config.start_week = 14

    # path to XML files for subjects and courses
    config.all_subjects_xml_url = 'https://stundenplan.htwk-leipzig.de/stundenplan/xml/public/semgrp_ss.xml'
    config.all_courses_xml_url  = 'https://stundenplan.htwk-leipzig.de/stundenplan/xml/public/modul_ss.xml'

    # ID of XML node in 'all_courses_xml_url' that contains all studium generale
    # modules
    config.studium_generale_fakultaet_id = '%23SPLUS905495'

    # base path for single schedule per subject and studium generale
    config.single_subjects_html_url   = 'https://stundenplan.htwk-leipzig.de/ss/Berichte/Text-Listen;Studenten-Sets;name;###SLUG###?template=UNEinzelGru&weeks=11-35'
    config.studium_generales_html_url = 'https://stundenplan.htwk-leipzig.de/ss/Berichte/Text-Listen;Module;id;###SLUG###?template=UNEinzelLV&weeks=11-35'
  end
end
