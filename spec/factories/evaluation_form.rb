FactoryBot.define do
  factory :evaluation_form do
    # Associations
    association :challenge
    association :phase

    # Fields
    title { "#{Faker::Lorem.word.humanize} Evaluation Form" }
    instructions { Faker::Lorem.sentence(word_count: 10) }
    closing_date { Faker::Date.forward(days: 30) }
    comments_required { Faker::Boolean.boolean }
    weighted_scoring { Faker::Boolean.boolean }

    # Factory options
    trait :with_comments do
      comments_required { true }
    end

    trait :weighted do
      weighted_scoring { true }
    end
  end
end
