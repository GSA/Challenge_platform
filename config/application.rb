# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsNew
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Use the Postgresql-specific syntax for DB dumps
    config.active_record.schema_format = :sql

    config.app_domain = ENV.fetch("APP_DOMAIN", nil)

    # Shared login.gov config with ENV overrides
    config.login_gov_oidc = {
      idp_host: ENV.fetch("LOGIN_IDP_HOST", "https://idp.int.identitysandbox.gov"),
      login_redirect_uri: ENV.fetch("LOGIN_REDIRECT_EVAL_URL", "https://challenge-dev.app.cloud.gov/auth/result"),
      logout_redirect_uri: ENV.fetch("LOGOUT_REDIRECT_EVAL_URL", "https://challenge-dev.app.cloud.gov/"),
      acr_value: "http://idmanagement.gov/ns/assurance/loa/1",
      client_id: ENV.fetch("LOGIN_CLIENT_ID", "urn:gov:gsa:openidconnect.profiles:sp:sso:gsa:_client_id"), # default fake ID for CI
      private_key_password: ENV.fetch("LOGIN_PRIVATE_KEY_PASSWORD", nil), # optional
      public_key_path: ENV.fetch("LOGIN_PUBLIC_KEY_PATH", "config/public.crt"),
      private_key_path: ENV.fetch("LOGIN_PRIVATE_KEY_PATH", "config/private.pem"),
    }

    config.phx_interop = {
      phx_uri: ENV.fetch("PHOENIX_URI", nil),
      login_secret: ENV.fetch("LOGIN_SECRET", "login_secret_123"),
      jwt_secret: ENV.fetch("JWT_SECRET", "jwt_secret_123")
    }

    config.assets.initialize_on_precompile = false
  end
end
