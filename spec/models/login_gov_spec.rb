require 'rails_helper'

RSpec.describe LoginGov do
  subject(:login_gov) { described_class.new }

  let(:jwks_uri) { "#{login_gov.config[:idp_host]}/api/openid_connect/certs" }
  let(:end_session_endpoint) { "#{login_gov.config[:idp_host]}/openid_connect/logout" }
  let(:code_param) { "ABC123" }
  let(:public_key) do
    { keys: [{ alg: "RS256", use: "sig", kty: "RSA", n: "a-key-here", e: "AQAB", kid: "a-kid-here" }] }
  end
  let(:private_key) do
    key = <<~EOKEY
      -----BEGIN PRIVATE KEY-----
      MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDXqeVJEPMpNfPv
      CAW6e1mL6UXaH3/1EyLD6G872+yucwV+Rm7ee5FSjM3y0O/u491mmNWtdTvJSNez
      2IiJ1MrnRXbbTJGAZXKai1D4EdTmeLbum4f5OBtNt+I6QgBV6IuFnJNLN7N5dwLC
      87bdOxyVtXMB/pM5lbzz3AYiaYqi0VBL73qnQsIQhx4YApADrfiDEJEWStPkk0XV
      teCuh1TdzJieIswh1Vz7WbvoGAaQZIGJAGx4kLGw8EBH2p4Rlz92M9trYYTYkKTk
      kz847JiIXpqDX13J6gPQBqRKy4znLXnG/NDkd+WkJtMu8M233OwVgzpHupuFMCpl
      gF10ugchAgMBAAECggEAAM7E8BNpdFL+rvpdM36wOlZT46g0IsQOV/JhG/f4MXVY
      7exvg5q0YJjy07nXSgAbPsVRXwzl4Q16VSpJPso0G+sE78QySGPMm9eWyfIv2bca
      TDADtNt+A+tFC9GRdAuUeZ+IQnBlAM0xDHGOyAnNw/kwF07CN8WHzkLiKZ1fZo9s
      L8JdUxl8hLnwyx1JwCTXTy55VM3bFMQVdV9qH/m4bGYoB4ezKAfM+rLaLTAr2tpW
      EzrMbqN6+EGu4uj2wCQsK56oaCatRVdtmwDugQQafh0WLkkqMx6pRzpBfUBUMDXW
      S9nqLJIm01z28W6jYPkoMfarYNj80YtQ5c/Ug7JAEQKBgQDe8SAvdIr+1nbA6/kQ
      snDl8Lv1uZ8Q+9WLrsR5cWnV+HshDNIlLZBTsNAO+rPKbnAAM5rJfE9EArI/NHzo
      rONY7g3PLmxI2OWCsoQSd7vhsYa/8To5ui+3xq45YGzEbzryDFtz7hKu7hqitqh1
      rBFgAeqPkGn+KKJWWyw+VNxq8QKBgQD3pHzjNHq8rE1VMTOs6BHHxPAUKPBI0zay
      x3Q7k+62xGpO/vyFs/lxgUMsQdZzXD8PKAKw/yd6vY7oxJEw+qhfMpSEaJKGu3P2
      RhkpjMI77g76UeIpH3zDGRJ7/LrY7KrWuydCBkvEo6hTA40hoO2wxwMKJDfL0xBK
      OgaHnTx/MQKBgQCYtJ0RJEjYyVnKR1fwoelG9yAn7h8QaQ8agHk/nfmagHsGZlvC
      73S+fovk1sAz1nWNDcvmWumIcjhZpsAwN8v57AU1dlzhgP+kCFcCt1TQAOOFsdvq
      EqgAv2wzDOMzoeTESsaRn+7YN2uzLF4zS8sS8f0SnR6c4oRflk+12jaoYQKBgEDP
      y9+q3HSEo7ioJ94Y3o5p/GtKS5jDro0bpk/xZ4ht32TNV0mm0KHkMrBiir2mZtqQ
      niO0o6B7++rvhxBKicZgdn4w4Chi5vaNYgh9zlfg9gqNY6Nfmkd1SGEqw7wCNLP+
      R0gAXdQZAPS4+TbT52FctG7zC6dMlfbXON5FSJABAoGAcCzhCkP19Sh7hs7tlqU1
      is7X2LBTs0CBkeeYFIYxiC4CpIGCLh9DcyOLGoAUdq8JtgXswzMiVG5I6dMXOaRc
      wFJMAMO1uF/Re/5d/5Ne0ZsD47WuJQRrIgMcwAg8JZsTNZYI/iULYUih01dDIqlH
      OlpC0cZTHY05PpP7uX4gq1k=
      -----END PRIVATE KEY-----
    EOKEY
    OpenSSL::PKey.read key
  end
  let(:id_token) { "my-token-id" }
  let(:user_info) do
    [
      {
        "sub" => "sub",
        "iss" => "https://idp.int.identitysandbox.gov/",
        "email" => "test@example.gov",
        "email_verified" => true,
        "ial" => "http://idmanagement.gov/ns/assurance/ial/1",
        "aal" => "urn:gov:gsa:ac:classes:sp:PasswordProtectedTransport:duo",
        "nonce" => "nonce",
        "aud" => "urn:gov:gsa:openidconnect.profiles:sp:sso:gsa:challenge_gov_platform_dev",
        "jti" => "jti",
        "at_hash" => "hash-EQg7x1gw",
        "c_hash" => "hash-KnQ",
        "acr" => "http://idmanagement.gov/ns/assurance/ial/1",
        "exp" => 1_721_696_128,
        "iat" => 1_721_695_228,
        "nbf" => 1_721_695_228
      }, {
        "kid" => "abc10930230928df",
        "alg" => "RS256"
      }
    ]
  end

  before do
    stub_request(:get, login_gov.well_known_configuration_url).
      to_return(body: {
        jwks_uri:,
        end_session_endpoint:
      }.to_json)
  end

  describe '#exchange_token_from_auth_result' do
    it 'raises error if request fails' do
      stub_request(:get, login_gov.well_known_configuration_url).
        to_return(body: '', status: 401)

      expect { login_gov.exchange_token_from_auth_result code_param }.
        to raise_error(LoginGov::LoginApiError)
    end

    it 'returns userinfo on success' do
      # mock the encryption and http requests
      jwks = class_double(JWT::JWK::Set, new: "jwks double")
      allow(login_gov).to receive(:get_public_key).with(jwks_uri) { public_key } # rubocop:disable RSpec/SubjectStub
      allow(login_gov).to receive(:read_private_key) { private_key } # rubocop:disable RSpec/SubjectStub
      allow(JWT::JWK::Set).to receive(:new).with(public_key) { jwks }
      stub_request(:post, login_gov.token_endpoint_url).to_return(
        status: 200,
        body: "{\"id_token\": \"#{id_token}\"}",
        headers: {}
      )
      allow(JWT).to receive(:decode).with(id_token, nil, true, algorithms: ["RS256"], jwks:).and_return(user_info)
      actual = login_gov.exchange_token_from_auth_result code_param
      expect(actual).to eq(user_info)
    end
  end
end
