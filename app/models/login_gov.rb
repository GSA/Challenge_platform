class LoginGov

  class LoginApiError < StandardError
    attr_reader :status_code, :response_body

    def initialize(msg, code:, body:)
      @status_code = code
      @response_body = body
      super(msg)
    end
  end

  # :acr_value,
  # :client_id,
  # :idp_host,
  # :login_redirect_uri,
  # :logout_redirect_uri,
  # :private_key_password,
  # :private_key_path,
  attr_reader :config

  def initialize(config = Rails.configuration.login_gov_oidc)
    @config = config.freeze.dup
  end

  def client_id
    config[:client_id]
  end

  def authorization_url
    query = {
      client_id: client_id,
      response_type: "code",
      acr_values: config[:acr_value],
      scope: "openid email",
      redirect_uri: config[:login_redirect_uri],
      state: random_value(),
      nonce: random_value(),
      prompt: "select_account"
    }.to_query

    "#{config[:idp_host]}/openid_connect/authorize?#{query}"
  end 

  def logout_url
    query = {
      client_id: client_id,
      post_logout_redirect_uri: config[:logout_redirect_uri]
    }.to_query

    "#{config[:idp_host]}/openid_connect/logout?#{query}"
  end

  def well_known_configuration_url
    config[:idp_host] + "/.well-known/openid-configuration"
  end

  def token_endpoint_url
    config[:idp_host] + "/api/openid_connect/token"
  end

  def exchange_token_from_auth_result code_param
    # fetch the well-known configuration template data from login.gov
    openid_config = get_well_known_configuration

    # read the private key from local file system
    private_key = read_private_key

    # fetch the public_key from the well-known configuration jwks_uri
    jwks_uri = openid_config.fetch("jwks_uri")
    public_key = get_public_key(jwks_uri)
  
    # build the client assertion
    claims = {
      iss: client_id,
      sub: client_id,
      aud: token_endpoint_url,
      jti: random_value(),
      nonce: random_value(),
      exp: DateTime.now.utc.to_i + 1000
    }
    jwt_assertion = JWT.encode(claims, private_key, 'RS256')
    jwks = JWT::JWK::Set.new(public_key)

    # send the assertion for validation against the code param and return the user_info
    assertion_json = send_assertion(code_param, jwt_assertion)
    id_token = assertion_json.fetch("id_token")
    JWT.decode(id_token, nil, true, algorithms: ["RS256"], jwks: jwks)
  end

  def get_well_known_configuration
    response = Faraday.get(well_known_configuration_url) 
    if response.status != 200
      raise LoginApiError.new("well-known/openid-configuration error", code: response.status, body: response.body)
    end

    JSON.parse(response.body)
  end

  def get_public_key jwks_uri
    response = Faraday.get(jwks_uri)
    if response.status != 200
      raise LoginApiError.new("jwks_uri error", code: response.status, body: response.body)
    end

    JSON.parse(response.body)
  end

  def read_private_key
    key_path = config[:private_key_path]
    key_pass = config[:private_key_password]
    decrypted_key = if key_pass.nil?
      # private key is not password protected
      OpenSSL::PKey.read File.read(key_path)
    else
      OpenSSL::PKey.read File.read(key_path), key_pass
    end

    decrypted_key
  end

  def send_assertion code, jwt_assertion
    json_body = JSON.generate({
      grant_type: "authorization_code",
      code: code,
      client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
      client_assertion: jwt_assertion
    })
    
    response = Faraday.post(token_endpoint_url, json_body, content_type: "application/json")
    if response.status != 200
      raise LoginApiError.new("client assertion failed", code: response.status, body: response.body)
    end

    JSON.parse(response.body)
  end

  private

  def random_value
    SecureRandom.hex(16)
  end
end