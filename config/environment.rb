# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
#require 'array'
require File.join(File.dirname(__FILE__), '..', 'lib/array')
require File.join(File.dirname(__FILE__), '..', 'lib/string')
#require File.join(File.dirname(__FILE__), '..', 'lib/timer')
require File.join(File.dirname(__FILE__), '..', 'lib/fixnum')
require File.join(File.dirname(__FILE__), '..', 'lib/nil_class')
#require File.join(File.dirname(__FILE__), '..', 'lib/rails_info')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/app/models/ckeditor )

  # Specify gems that this application depends on and have them installed with rake gems:install
    #config.gem "ckeditor"
    #config.gem "rmagick", :version => '2.10.0'
   RMAGICK_BYPASS_VERSION_TEST = true                                                            #shit (i.e. rmagick) happens
    config.gem "will_paginate"
    config.gem "haml", :version => '3.0.25'
    config.gem "redhillonrails_core"
   #duplicate rbbcode
    config.gem "bb-ruby"                                                                          #TODO: remove line
    config.gem "validates_captcha"
    config.gem "simple-password-gen"
    config.gem "paperclip"
    config.gem "validates_email_format_of"
    config.gem "validates_existence"
    config.gem "rbbcode"
    config.gem "whenever"
    config.gem "cucumber", :lib => false, :version => '0.10.3'                                    #it's plugin now
    config.gem "cucumber-rails", :lib => false, :version => '0.3.2'                             #it's plugin now
    config.gem "rspec", :lib => false, :version => '1.2.9'                                                #it's plugin now  
    config.gem "rspec-rails", :lib => false, :version => '1.2.9'                                      #it's plugin now
    config.gem "mimemagic"
    config.gem "gherkin", :version => '2.3.8'
    config.gem "i18n"
    config.gem "flexmock"
    # config.gem "captcha"
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

    # config.plugins = [:all]
#  config.plugins = ['rspec', 'rspec-rails']

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  config.action_mailer.delivery_method = :smtp
  config.action_controller.session_store = :active_record_store
  
  #config.encoding = "utf-8"

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  #config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.default_locale = :en
end
