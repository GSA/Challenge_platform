FactoryBot.define do
  factory :submission do
    # Associations
    association :challenge
    association :phase
    association :submitter, factory: :user
    # don't think we need this anymore?
    # association :manager, factory: :user

    title { Faker::Lorem.sentence }
    status { "draft" }
  end
end
