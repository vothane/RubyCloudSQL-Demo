# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_RubyCloudSQL Demo_session',
  :secret      => '2072ba38fc9b03cdf4d45042f814af98903284b94bf6647b04a044846ccce44f7a9cb973665d4daac32a37f6321ef329ed47e5d3edbfa9817270afa1f41ac403'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
