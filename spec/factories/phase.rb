FactoryBot.define do
  factory :phase do
    association :challenge
    uuid { SecureRandom.uuid }
    title { Faker::Lorem.sentence }
    start_date { Faker::Date.backward(days: 30) }
    end_date { Faker::Date.forward(days: 30) }
    open_to_submissions { Faker::Boolean.boolean }
    judging_criteria { Faker::Lorem.paragraph }
    judging_criteria_delta { Faker::Lorem.paragraph }
    how_to_enter { Faker::Lorem.paragraph }
    how_to_enter_delta { Faker::Lorem.paragraph }

    after(:build) do |phase|
      phase.judging_criteria_length = phase.judging_criteria.length
      phase.how_to_enter_length = phase.how_to_enter.length
    end
  end
end
