FactoryBot.define do
  factory :evaluator_submission_assignment do
    # Associations
    association :evaluator, factory: :user
    association :submission

    status { %w[assigned unassigned recused].sample }
  end
end