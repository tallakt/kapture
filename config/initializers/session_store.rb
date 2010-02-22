# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_kapture_session',
  :secret      => 'd9c86a24d6ff5f82794008a444ea40d25a50a368f53193634f80c199327837ba6fc8fd16f42a2429cc4349c40e3ad3e53c6ec2372ca8c26b2b279c349970c541'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
