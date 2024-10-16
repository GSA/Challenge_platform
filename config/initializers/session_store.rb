Rails.application.config.session_store :cookie_store, key: '_challenge_platform_key', 
  domain: Rails.configuration.app_domain,
  secure: !Rails.env.development?,
  same_site: :lax 