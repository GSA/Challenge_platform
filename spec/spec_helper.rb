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

def log_in_user(user)
  code = "ABC123"
  mock_login_gov(user, code)

  get "/auth/result", params: { code: }
end

def create_and_log_in_user(user_attrs = {})
  user = create_user(user_attrs)
  code = "ABC123"
  mock_login_gov(user, code)

  get "/auth/result", params: { code: }
  user
end

def create_user(attrs = {})
  email = "#{SecureRandom.hex}@example.gov"
  token = SecureRandom.uuid
  role = "challenge_manager"
  attrs = { email:, token:, role: }.merge(attrs)
  User.create!(attrs)
end

def create_challenge(attrs = {})
  user = attrs[:user] || create_user(role: :challenge_manager)
  agency = attrs[:agency] || create_agency
  title = attrs[:title] || "test challenge"
  end_date = attrs[:end_date] || Date.tomorrow
  challenge_manager_users = attrs[:challenge_manager_users] || [user]
  Challenge.create!(user:, agency:, title:, end_date:, challenge_manager_users:)
end

def create_phase(attrs = {})
  title = attrs[:title] || "test challenge"
  end_date = attrs[:end_date] || Date.tomorrow
  start_date = attrs[:start_date] || Time.zone.today
  challenge_id = attrs[:challenge_id] || create_challenge.id
  uuid = attrs[:uuid] || SecureRandom.uuid
  Phase.create!(title:, challenge_id:, start_date:, end_date:, uuid:)
end

def create_evaluation_form(attrs = {})
  title = attrs[:title] || "test challenge"
  challenge_id = attrs[:challenge_id] || create_challenge.id
  phase_id = attrs[:phase_id] || create_phase.id
  EvaluationForm.create!(title:, challenge_id:, phase_id:, instructions: "test instructions",
                         closing_date: Date.tomorrow)
end

def create_agency(attrs = {})
  name = attrs[:name] || "Test Agency"
  acronym = attrs[:acronym] || "FAA"
  Agency.create!(name:, acronym:)
end

def mock_login_gov(user, code = "ABC123") # rubocop:disable Metrics/AbcSize
  login_gov = instance_double(LoginGov)
  allow(LoginGov).to receive(:new).and_return(login_gov)
  allow(login_gov).to receive(:exchange_token_from_auth_result).with(code).and_return(
    [{ email: user.email, sub: user.token }]
  )

  allow_any_instance_of(SessionsController).to( # rubocop:disable RSpec/AnyInstance
    receive(:send_user_jwt_to_phoenix).with(instance_of(String)).and_return(true)
  )
end
