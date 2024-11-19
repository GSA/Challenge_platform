FactoryBot.define do
  factory :challenge_manager do
    association :challenge
    association :user
  end
end
