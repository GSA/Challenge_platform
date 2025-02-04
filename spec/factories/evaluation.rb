FactoryBot.define do
  factory :evaluation do
    association :user, :evaluator
    association :evaluation_form
    association :submission
    association :evaluator_submission_assignment

    total_score { nil }
    additional_comments { nil }
    revision_comments { nil }

    trait :completed do
      total_score { Random.rand(100) }
      completed_at { Time.current }
    end

    after(:create) do |evaluation, _evaluator|
      evaluation.evaluation_scores.each do |score|
        valid_score_for_criterion(score)
        score.comment ||= "Generated comment for #{score.evaluation_criterion.title}"

        # Triggers a save and cacluates calucated_score
        score.save!
      end

      # This triggers an evaluation save to calculate total_score
      evaluation.save!
    end
  end
end
