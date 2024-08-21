# config/initializer/session_store.rb
# Use cookie session storage in JSON format. Here, we scope the cookie to the root domain.
# Rails.application.config.session_store :cookie_store, key: '_rails_app_session', domain: ".#{ENV['DOMAIN']}"
Rails.application.config.session_store :cookie_store, key: '_rails_app_session', domain: "localhost"
Rails.application.config.action_dispatch.cookies_serializer = :json
# These salts are optional, but it doesn't hurt to explicitly configure them the same between the two apps.
# Rails.application.config.action_dispatch.encrypted_cookie_salt = ENV['SESSION_ENCRYPTED_COOKIE_SALT']
# Rails.application.config.action_dispatch.encrypted_signed_cookie_salt = ENV['SESSION_ENCRYPTED_SIGNED_COOKIE_SALT']"
Rails.application.config.action_dispatch.encrypted_cookie_salt = "+S7HWPoL"
Rails.application.config.action_dispatch.encrypted_signed_cookie_salt = "encryption salt"