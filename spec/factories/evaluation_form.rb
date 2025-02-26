FactoryBot.define do
  factory :evaluation_form do
    # Associations
    association :challenge
    phase { association(:phase, challenge: challenge) }

    # Fields
    instructions { Faker::Lorem.sentence(word_count: 10) }
    comments_required { Faker::Boolean.boolean }
    scale_type { [:point, :weight].sample }

    # Optional Attrs
    transient do
      evaluation_criteria_attrs { [] } # Allow passing in an array of criteria attributes
    end

    # Factory options
    trait :with_comments do
      comments_required { true }
    end

    trait :weighted do
      scale_type { "weight" }
    end

    trait :pointed do
      scale_type { "point" }
    end

    # Creates 1-10 evaluation_criterion
    # Assures proper points sum of 100 when weighted_scoring = 100
    # Skips initial validation on eval form create because of dependency
    before(:create) do
      if EvaluationForm._validate_callbacks.any? do |cb|
        cb.kind == :before && cb.filter == :criteria_weights_must_sum_to_one_hundred
      end
        EvaluationForm.skip_callback(:validate, :before, :criteria_weights_must_sum_to_one_hundred)
      end
    end

    after(:build) do |evaluation_form|
      if evaluation_form.phase&.end_date.present?
        phase_end_date = evaluation_form.phase.end_date
        evaluation_form.closing_date = phase_end_date + 1.day
      else
        # Fallback in case of no phase end_date
        closing_date { 4.months.from_now }
      end
    end

    after(:create) do |evaluation_form, evaluator|
      if evaluator.evaluation_criteria_attrs.any?
        evaluator.evaluation_criteria_attrs.each do |criterion_attrs|
          create(:evaluation_criterion, evaluation_form: evaluation_form, **criterion_attrs)
        end
      else
        num_criteria = rand(1..10)

        if evaluation_form.weighted_scoring?
          weights = Array.new(num_criteria) { rand(1..100) }
          total_weight = weights.sum.to_f
          normalized_weights = weights.map { |w| (w / total_weight * 100).round }

          normalized_weights[-1] += 100 - normalized_weights.sum

          normalized_weights.each do |weight|
            create(:evaluation_criterion, evaluation_form:, points_or_weight: weight)
          end
        else
          create_list(:evaluation_criterion, num_criteria, evaluation_form:)
        end
      end

      evaluation_form.reload
    ensure
      EvaluationForm.set_callback(:validate, :before, :criteria_weights_must_sum_to_one_hundred)
    end
  end
end
