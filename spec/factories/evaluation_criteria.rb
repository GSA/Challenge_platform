FactoryBot.define do
  factory :evaluation_criterion, class: 'EvaluationCriterion' do
    # Associations
    association :evaluation_form

    # Fields
    title { "Criterion #{Faker::Lorem.word}" }
    description { Faker::Lorem.sentence }
    points_or_weight { rand(0..100) }
    scoring_type { :numeric }
    option_range_start { 0 }
    option_range_end { 4 }
    option_labels { [] }

    # Factory options
    trait :numeric do
      scoring_type { :numeric }
    end

    trait :rating do
      scoring_type { :rating }
    end

    trait :binary do
      scoring_type { :binary }
    end
  end
end
