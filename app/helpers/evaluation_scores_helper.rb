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

  def evaluation_score_input(score_fields, field, criterion, identifier, opts)
    field_id = evaluation_score_id(score_fields, field, identifier)
    field_name = evaluation_score_name(score_fields, field, identifier)

    case criterion.scoring_type
    when 'numeric'
      score_numeric_input(score_fields, field, field_id, field_name, **opts)
    else # rating or binary
      content_tag(:div, class: "usa-fieldset") do
        score_options(criterion).each do |value, label|
          concat(score_radio_input(score_fields, value, label, field:, id: field_id, name: field_name, **opts))
        end
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def score_numeric_input(score_fields, field, id, name, opts)
    criterion = score_fields.object.evaluation_criterion
    min = 0
    max = criterion.points_or_weight

    content_tag(:div, class: "display-flex flex-column") do
      concat(score_fields.label(field,
                                I18n.t("evaluation_scores.instruction_text_numeric", min:, max:),
                                for: id, class: label_error_class(score_fields, :score)))
      if opts[:override]
        concat(content_tag(:p, "Evaluator's score", class: "text-base margin-bottom-0"))
        concat(content_tag(:div, score_fields.object.score, class: "usa-input width-10 bg-base-light",
                                                            style: "background: #c9c9c9"))
      end
      concat(content_tag(:p, "Revised score", class: "margin-bottom-0")) if opts[:override]
      concat(score_fields.number_field(
               field, id:, name:, min:, max:, class: "usa-input width-10",
                      data: {
                        'evaluation-score-target': "scoreInput",
                        action: "input->evaluation-score#calculateScore form-validation#validatePresence",
                        'field-label': "score"
                      }, disabled: opts[:disabled]
             ))
    end
  end
  # rubocop:enable Metrics/AbcSize

  def score_options(criterion)
    (criterion.option_range_start..criterion.option_range_end).map do |value|
      [value, criterion.option_labels[value.to_s] || value]
    end
  end

  # rubocop:disable Metrics/AbcSize
  def score_radio_input(score_fields, value, label, opts = {})
    id = opts[:id]
    opts[:disabled]
    criterion = score_fields.object.evaluation_criterion
    bg_class = selected_radio_bg_class(score_fields, value, **opts)

    if opts[:override] && score_fields.object.score == value
      concat(content_tag(:p, "Evaluator's score",
                         class: "text-base margin-top-2 margin-bottom-0"))
    end
    content_tag(:div, class: "usa-radio display-flex flex-align-center width-full") do
      concat(radio_button_tag(score_fields, value, opts))
      concat(radio_label_tag(score_fields, value, label, id))
      concat(radio_score_display(value, criterion, bg_class))
    end
  end
  # rubocop:enable Metrics/AbcSize

  def selected_radio_bg_class(score_fields, value, opts)
    score = opts[:override] ? score_fields.object.score_override.to_s : score_fields.object.score.to_s
    score == value.to_s && !opts[:disabled] ? "bg-primary" : "bg-base-dark"
  end

  def radio_button_tag(score_fields, value, opts)
    field, id, name, disabled = opts.values_at(:field, :id, :name, :disabled)
    options = radio_button_options(id, name, value, disabled)
    score_fields.radio_button(field, value, **options)
  end

  def radio_button_options(id, name, value, disabled)
    {
      id: "#{id}_#{value}",
      name:,
      class: "usa-radio__input usa-radio__input--tile",
      data: {
        'evaluation-score-target': "scoreInput",
        action: "change->evaluation-score#calculateScore form-validation#validatePresence",
        'field-name': id
      },
      disabled:
    }
  end

  def radio_label_tag(score_fields, value, label, id)
    score_fields.label("score_#{value}", label, for: "#{id}_#{value}", class: "usa-radio__label flex-1")
  end

  def radio_score_display(value, criterion, bg_class)
    content_tag(:div, radio_calculated_score(value, criterion),
                class: "radio-score-value display-flex flex-align-center flex-justify-center
              margin-top-1 margin-left-1 width-10 height-6 #{bg_class} text-base-lightest text-bold")
  end

  def radio_calculated_score(score, criterion)
    return "" unless criterion.points_or_weight && criterion.option_range_end

    scaled_score = (criterion.points_or_weight.to_f / criterion.option_range_end) * score
    format_score(scaled_score, criterion.evaluation_form.weighted_scoring?)
  end

  def format_score(score, weighted_scoring)
    formatted_score = score.round(2).to_s.sub(/\.0+$/, '')
    weighted_scoring ? "#{formatted_score}%" : formatted_score
  end
end
