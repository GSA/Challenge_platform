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

  def evaluation_score_input(score_fields, field, criterion, identifier, disabled)
    field_id = evaluation_score_id(score_fields, field, identifier)
    field_name = evaluation_score_name(score_fields, field, identifier)

    case criterion.scoring_type
    when 'numeric'
      score_numeric_input(score_fields, field, field_id, field_name, disabled)
    else # rating or binary
      content_tag(:div, class: "usa-fieldset") do
        score_options(criterion).each do |value, label|
          concat(score_radio_input(score_fields, value, label, field:, id: field_id, name: field_name, disabled:))
        end
      end
    end
  end

  def score_numeric_input(score_fields, field, id, name, disabled)
    criterion = score_fields.object.evaluation_criterion
    min = 0
    max = criterion.points_or_weight

    content_tag(:div, class: "display-flex flex-column") do
      concat(score_fields.label(field, I18n.t("evaluation_scores.instruction_text_numeric", min:, max:), for: id,
                                                                                                         class: label_error_class(score_fields, :score)))
      concat(score_fields.number_field(
               field, id:, name:, min:, max:, class: "usa-input width-10",
                      data: {
                        'evaluation-score-target': "scoreInput",
                        action: "input->evaluation-score#calculateScore form-validation#validatePresence",
                        'field-label': "score"
                      }, disabled:
             ))
    end
  end

  def score_options(criterion)
    (criterion.option_range_start..criterion.option_range_end).map do |value|
      [value, criterion.option_labels[value.to_s] || value]
    end
  end

  def score_radio_input(score_fields, value, label, opts = {})
    field = opts[:field]
    id = opts[:id]
    name = opts[:name]
    disabled = opts[:disabled]

    content_tag(:div, class: "usa-radio") do
      concat(score_fields.radio_button(
               field, value, id: "#{id}_#{value}", name:, class: "usa-radio__input usa-radio__input--tile",
                             data: {
                               'evaluation-score-target': "scoreInput",
                               action: "change->evaluation-score#calculateScore form-validation#validatePresence",
                               'field-name': id
                             },
                             disabled:
             ))
      concat(score_fields.label("score_#{value}", label, for: "#{id}_#{value}", class: "usa-radio__label"))
    end
  end
end
