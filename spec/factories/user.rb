FactoryBot.define do
  factory :user do
    # Associations
    agency

    # Fields
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { generate_user_email }
    phone_number { Faker::PhoneNumber.cell_phone }
    token { SecureRandom.uuid }
    role { User::ROLES.sample }
    password_hash { "hashed_password" }
    status { "active" }
    finalized { true }
    display { true }
    avatar_key { SecureRandom.uuid }
    avatar_extension { "jpg" }
    terms_of_use { Time.zone.now }
    privacy_guidelines { Time.zone.now }
    last_active { Time.zone.now }
    active_session { Faker::Boolean.boolean }
    jwt_token { Faker::Internet.password(min_length: 20, max_length: 30) }
    recertification_expired_at { 1.year.from_now }
    ial_level { 1 }

    # Factory options
    trait :super_admin do
      role { "super_admin" }
    end

    trait :admin do
      role { "admin" }
    end

    trait :challenge_manager do
      role { "challenge_manager" }
    end

    trait :evaluator do
      role { "evaluator" }
    end

    trait :solver do
      role { "solver" }
    end

    trait :pending do
      status { "pending" }
    end

    trait :email_verified do
      email_verified_at { Time.zone.now }
      email_verification_token { nil }
    end

    trait :gov do
      email { generate_user_email(type: :gov) }
    end

    trait :non_gov do
      email { generate_user_email(type: :non_gov) }
    end
  end
end

def generate_user_email(type: :default)
  case type
  when :default
    Faker::Internet.email
  when :gov
    domain = "example.#{%w[gov mil].sample}"
    Faker::Internet.email(domain:)
  when :non_gov
    Faker::Internet.email(domain: "example.com")
  end
end
