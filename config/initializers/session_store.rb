# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => 'orientisrbb_session',
  :secret      => '90a8afcf2d1eb12dd747ae8cd6fad426fa8c98916166ad819487dcdc1e68d92cef752fb460b96d35f6d3d6f808b5219fc8a85aaeb28115bcb3751cf8e16baff4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
 ActionController::Base.session_store = :active_record_store
