# frozen_string_literal: true

# View helpers for evaluation score form inputs
module EvaluationScoresHelper
  def evaluation_score_id(_form, attribute, identifier)
    prefix = "evaluation_evaluation_scores_attributes"

    "#{prefix}_#{identifier}_#{attribute}"
  end

  def evaluation_score_name(_form, attribute, identifier)
    prefix = "evaluation[evaluation_scores_attributes]"

    "#{prefix}[#{identifier}][#{attribute}]"
  end

  def evaluation_score_input(score_fields, criterion, identifier)
    field_id = evaluation_score_id(score_fields, :score, identifier)
    field_name = evaluation_score_name(score_fields, :score, identifier)

    case criterion.scoring_type
    when 'numeric'
      score_numeric_input(score_fields, field_id, field_name)
    else # rating or binary
      content_tag(:div, class: "usa-fieldset") do
        score_options(criterion).each do |value, label|
          concat(score_radio_input(score_fields, value, label, id: field_id, name: field_name))
        end
      end
    end
  end

  def score_numeric_input(score_fields, id, name)
    criterion = score_fields.object.evaluation_criterion
    min = 0
    max = criterion.points_or_weight

    content_tag(:div, class: "display-flex flex-column") do
      # TODO: Should the lowest be 1?
      concat(score_fields.label(:score, "Enter a number between #{min} and #{max}", for: id))
      concat(score_fields.number_field(:score, id:, name:, min:, max:, class: "usa-input width-10"))
    end
  end

  def score_options(criterion)
    (criterion.option_range_start..criterion.option_range_end).map do |value|
      [value, criterion.option_labels[value.to_s] || value]
    end
  end

  def score_radio_input(score_fields, value, label, opts = {})
    id = opts[:id]
    name = opts[:name]

    content_tag(:div, class: "usa-radio") do
      concat(score_fields.radio_button(:score, value, id: "#{id}_#{value}", name:,
                                                      class: "usa-radio__input usa-radio__input--tile"))
      concat(score_fields.label("score_#{value}", label, for: "#{id}_#{value}", class: "usa-radio__label"))
    end
  end
end
