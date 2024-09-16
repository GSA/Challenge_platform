require 'simplecov'
require 'webmock/rspec'
require 'securerandom'

SimpleCov.command_name 'RSpec'

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def create_and_log_in_user(user_attrs = {})
  user = create_user(user_attrs)
  code = "ABC123"
  login_gov = instance_double(LoginGov)
  allow(LoginGov).to receive(:new).and_return(login_gov)
  allow(login_gov).to receive(:exchange_token_from_auth_result).with(code).and_return(
    [{ email: user.email, sub: user.token }]
  )

  get "/auth/result", params: { code: }
  user
end

def create_user(user_attrs = {})
  email = "testsolver@example.gov"
  token = SecureRandom.uuid
  user_attrs = { email:, token: }.merge(user_attrs)
  User.create!(user_attrs)
end
