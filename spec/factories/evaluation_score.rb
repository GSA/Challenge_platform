FactoryBot.define do
  factory :evaluation_score do
    association :evaluation
    association :evaluation_criterion
    score { nil }
    score_override { nil }
    comment { Faker::Lorem.sentence }
    comment_override { nil }

    # Evaluator is a FactoryBot param containing attributes from the factory record
    after(:build) do |evaluation_score, _evaluator|
      criterion = evaluation_score.evaluation_criterion

      case criterion.scoring_type
      when "numeric"
        evaluation_score.score = rand(0..criterion.points_or_weight)
      when "rating", "binary"
        evaluation_score.score = rand(criterion.option_range_start..criterion.option_range_end)
      else
        raise ArgumentError, "Invalid scoring type '#{criterion.scoring_type}' for evaluation criterion"
      end
    end
  end
end
