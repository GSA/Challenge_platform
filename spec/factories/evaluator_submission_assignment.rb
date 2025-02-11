FactoryBot.define do
  factory :evaluator_submission_assignment do
    # Associations
    association :evaluator, factory: [:user, :evaluator]
    association :submission

    status { %w[assigned unassigned recused].sample }

    trait :assigned do
      status { "assigned" }
    end

    trait :recused do
      status { "recused" }
    end

    trait :in_progress do
      association :evaluation
    end

    trait :completed do
      association :evaluation, :completed
    end
  end
end
