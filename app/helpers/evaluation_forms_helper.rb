# frozen_string_literal: true

module EvaluationFormsHelper
  def status_colors
    {
      draft: "FireBrick",
      ready: "DarkGoldenRod",
      published: "green"
    }
  end

  def challenge_with_phase(evaluation_form)
    "#{evaluation_form.challenge.title} - Phase #{evaluation_form.challenge_phase}"
  end

  def criteria_field_id(form, attribute, is_template)
    prefix = "evaluation_form_evaluation_criteria_attributes"

    if is_template
      "#{prefix}_NEW_CRITERIA_#{attribute}"
    else
      "#{prefix}_#{form.options[:child_index]}_#{attribute}"
    end
  end

  def criteria_field_name(form, attribute, is_template)
    prefix = "evaluation_form[evaluation_criteria_attributes]"

    if is_template
      "#{prefix}[NEW_CRITERIA][#{attribute}]"
    else
      "#{prefix}[#{form.options[:child_index]}][#{attribute}]"
    end
  end
end
