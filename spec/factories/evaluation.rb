FactoryBot.define do
  factory :evaluation do
    association :user, :evaluator
    association :evaluation_form
    status { :not_started }
    total_score { nil }
    additional_comments { nil }
    revision_comments { nil }

    after(:create) do |evaluation, _evaluator|
      evaluation.evaluation_form.evaluation_criteria.each do |criterion|
        create(:evaluation_score, evaluation_criterion: criterion, evaluation:)
      end
    end
  end
end
