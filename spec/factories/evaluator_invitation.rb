FactoryBot.define do
  factory :evaluator_invitation do
    # Associations
    association :challenge
    association :phase

    # Fields
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    last_invite_sent { Time.current }
  end
end
