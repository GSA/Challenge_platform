require 'rails_helper'

RSpec.describe LoginGov do
  let(:login_gov_config) do
    {
      idp_host: 'http://localhost:3003',
      login_redirect_uri: "http://localhost:3000/auth/result",
      logout_redirect_uri: "https://www.challenge.gov/",
      acr_value: "http://idmanagement.gov/ns/assurance/loa/1",
      client_id: "urn:gov:gsa:openidconnect.profiles:sp:sso:gsa:challenge_gov_platform_dev",
      private_key_password: nil,
      private_key_path: "config/private.pem",
      public_key_path: "config/public.crt",
    }
  end
  let(:jwks_uri) { "#{host}/api/openid/certs" }
  let(:end_session_endpoint) { "#{host}/openid/logout" }

  subject(:login_gov) { LoginGov.new(login_gov_config) }

  before do
    stub_request(:get, login_gov.well_known_configuration_url).
      to_return(body: {
        authorization_endpoint: authorization_endpoint,
        token_endpoint: token_endpoint,
        jwks_uri: jwks_uri,
        end_session_endpoint: end_session_endpoint,
      }.to_json)
  end

  describe '#exchange_token_from_auth_result' do
    it 'raises error if request fails' do
      stub_request(:get, login_gov.well_known_configuration_url).
        to_return(body: '', status: 401)

      expect { LoginGov::OidcSinatra::OpenidConfiguration.live }.
        to raise_error(LoginGov::OidcSinatra::AppError)
    end
  end

  describe '#cached' do
    it 'does not make more than one HTTP request' do
      oidc_config = LoginGov::OidcSinatra::OpenidConfiguration.cached
      cached_oidc_config = LoginGov::OidcSinatra::OpenidConfiguration.cached
      expect(oidc_config).to eq cached_oidc_config
      expect(a_request(:get, configuration_uri)).to have_been_made.once
    end
  end
end
