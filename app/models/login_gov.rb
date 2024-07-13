class LoginGov

  # :acr_value,
  # :client_id,
  # :idp_host,
  # :login_redirect_uri,
  # :logout_redirect_uri,
  # :logout_uri,
  # :private_key_password,
  # :private_key_path,
  # :token_endpoint,
  attr_reader :config

  def initialize(config = Rails.configuration.login_gov_oidc)
    @config = config.freeze.dup
  end

  def authorization_url
    query = {
      client_id: config[:client_id],
      response_type: "code",
      acr_values: config[:acr_value],
      scope: "openid email",
      redirect_uri: config[:login_redirect_uri],
      state: SecureRandom.hex(16),
      nonce: SecureRandom.hex(16),
      prompt: "select_account"
    }.to_query

    "#{config[:idp_host]}/openid_connect/authorize?#{query}"
  end 

  def logout_url
    query = {
      client_id: config[:client_id],
      post_logout_redirect_uri: config[:logout_redirect_uri]
    }.to_query

    "#{config[:logout_uri]}?#{query}"
  end

  def well_known_configuration_url
    config[:idp_host] + "/.well-known/openid-configuration"
  end

  def get_well_known_configuration
    response = Faraday.get(well_known_configuration_url) 
    [response.status, response.body]
  end

  def private_key
    key_path = config[:private_key_path]
    key_pass = config[:private_key_password]
    Rails.logger.info("Get private key from .pem file=#{key_path} pass=#{key_pass}")
    "🔐"
  end
end