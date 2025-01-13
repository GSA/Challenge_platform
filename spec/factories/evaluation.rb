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
      evaluation.evaluation_form.evaluation_criteria.each do |criterion|
        create(:evaluation_score, evaluation_criterion: criterion, evaluation:)
      end
    end
  end
end
