FactoryBot.define do
  factory :submission do
    # Associations
    association :challenge
    association :phase
    association :submitter, factory: :user

    title { Faker::Lorem.sentence }
    status { "submitted" }
    external_url { "www.example.com" }
  end
end
