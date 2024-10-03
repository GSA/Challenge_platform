FactoryBot.define do
  factory :user do
    # Associations
    agency

    # Fields
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
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
  end
end
