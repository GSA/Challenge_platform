# frozen_string_literal: true

# View helpers for rendering evaluation forms.
module EvaluationFormsHelper
  def challenge_with_phase(evaluation_form)
    challenge_phase_title(evaluation_form.challenge, evaluation_form.phase)
  end

  def challenge_phase_title(challenge, phase)
    title = challenge.title
    title += " - Phase #{phase_number(challenge, phase)}" if challenge.is_multi_phase?
    title
  end

  def options_for_available_phases(available_phases)
    available_phases.flat_map do |entry|
      challenge = entry[:challenge]
      entry[:phases].map do |phase|
        [
          challenge_phase_title(challenge, phase).to_s,
          "#{challenge.id}.#{phase.id}.#{phase.end_date.strftime('%m/%d/%Y')}"
        ]
      end
    end
  end

  def evaluation_period(evaluation_form)
    start_date = evaluation_form.phase.end_date.strftime("%m/%d/%Y")
    end_date = evaluation_form.closing_date.strftime("%m/%d/%Y")

    "#{start_date} - #{end_date}"
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

  def eval_form_disabled?(evaluation_form)
    evaluation_form.valid? && evaluation_form.phase.end_date < Time.zone.today
  end
end
