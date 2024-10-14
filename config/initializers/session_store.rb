Rails.application.config.session_store :cookie_store, key: '_challenge_platform_key', 
  domain: Rails.configuration.session_cookie_domain,
  secure: !Rails.env.development?,
  same_site: :lax 