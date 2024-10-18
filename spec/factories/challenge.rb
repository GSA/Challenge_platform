FactoryBot.define do
  factory :challenge do
    # Associations
    user
    agency
    sub_agency { association(:agency) }

    # Fields
    title { "#{Faker::Lorem.word.humanize} Challenge" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    description_delta { Faker::Lorem.paragraph(sentence_count: 3) }
    brief_description { Faker::Lorem.sentence }
    brief_description_delta { Faker::Lorem.sentence }
    tagline { Faker::Lorem.sentence }
    prize_total { Faker::Number.between(from: 10_000, to: 100_000) }
    judging_criteria { Faker::Lorem.sentence }
    prize_description { Faker::Lorem.sentence }
    prize_description_delta { Faker::Lorem.sentence }
    status { "draft" }
    captured_on { Time.zone.today }
    start_date { 1.month.from_now }
    end_date { 3.months.from_now }
    auto_publish_date { 1.week.from_now }
    published_on { 2.weeks.from_now }
    custom_url { Faker::Internet.url(host: "example.com", path: "/custom/#{SecureRandom.hex(8)}") }
    external_url { Faker::Internet.url(host: "example.com", path: "/external") }
    agency_name { Faker::Company.name }
    fiscal_year { "2024" }
    challenge_manager { Faker::Name.name }
    challenge_manager_email { Faker::Internet.email }
    terms_and_conditions { Faker::Lorem.paragraph(sentence_count: 2) }
    terms_and_conditions_delta { Faker::Lorem.paragraph(sentence_count: 2) }
    legal_authority { Faker::Lorem.sentence }
    faq { Faker::Lorem.paragraph(sentence_count: 2) }
    multi_phase { Faker::Boolean.boolean }
    prize_type { %w[monetary non_monetary both].sample }
    winner_information { Faker::Lorem.sentence }
    eligibility_requirements { Faker::Lorem.sentence }
    submission_collection_method { %w[internal external].sample }
    gov_delivery_subscribers { Faker::Number.between(from: 100, to: 5000) }
    uuid { SecureRandom.uuid }
    is_multi_phase { Faker::Boolean.boolean }

    # Optional fields
    deleted_at { nil }
    archive_date { nil }

    # TODO: Possibly fix phases association
    # after(:create) do |challenge|
    #   create_list(:phase, 1, challenge: challenge)
    # end

    factory :published_challenge do
      status { "published" }
    end
  end
end
