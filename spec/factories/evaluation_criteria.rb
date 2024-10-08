FactoryBot.define do
  factory :evaluation_criterion, class: 'EvaluationCriterion' do
    # Associations
    association :evaluation_form

    # Fields
    title { "Criterion #{Faker::Lorem.word}" }
    description { Faker::Lorem.sentence }
    points_or_weight { rand(0..100) }
    scoring_type { [:numeric, :rating, :binary].sample }
    option_range_start { nil }
    option_range_end { nil }
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

    after(:build) do |criterion|
      case criterion.scoring_type
      when "numeric"
      # All nil
      when "rating"
        criterion.option_range_start = 0
        criterion.option_range_end = 4
      when "binary"
        criterion.option_range_start = 0
        criterion.option_range_end = 1
        criterion.option_labels = %w[no yes]
      end
    end
  end
end
