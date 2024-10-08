FactoryBot.define do
  factory :agency do
    # Associations
    parent { nil } # Only present on a sub_agency

    # Fields
    name { "#{Faker::Lorem.word.humanize} Agency" }
    description { Faker::Lorem.sentence }
    acronym { Faker::Lorem.words(number: 3).map { |word| word[0].upcase }.join }
    avatar_key { SecureRandom.uuid }
    avatar_extension { "jpg" }
    created_on_import { false }

    # Factory options
    factory :sub_agency do
      association :parent, factory: :agency
    end
  end
end
