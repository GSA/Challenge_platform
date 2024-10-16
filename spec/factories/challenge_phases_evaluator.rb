FactoryBot.define do
  factory :challenge_phases_evaluator do
    # Associations
    association :challenge
    association :phase
    association :user
  end
end
