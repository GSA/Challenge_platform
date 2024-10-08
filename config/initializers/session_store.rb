Rails.application.config.session_store :cookie_store, key: '_challenge_platform_key', 
  domain: Rails.configuration.app_domain,
  tld_length: 2, 
  same_site: :lax 