Rails.application.config.session_store :cookie_store, key: '_challenge_platform_key', 
  domain: ENV.fetch("APP_DOMAIN", nil),
  tld_length: 2, 
  same_site: :lax 