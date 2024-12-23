FactoryBot.define do
  factory :submission do
    # Associations
    association :challenge
    association :phase
    association :submitter, factory: :user
    association :manager, factory: :user

    title { Faker::Lorem.sentence }
    status { "draft" }
    external_url { "www.example.com" }
  end
end
