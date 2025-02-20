# frozen_string_literal: true

# This service handles evaluation draft and completion actions
class EvaluationSavingService
  def initialize(evaluation, subaction)
    @evaluation = evaluation
    @subaction = subaction
  end

  def call
    if complete_evaluation?
      mark_as_complete
    else
      save_as_draft
    end
  end

  private

  def complete_evaluation?
    @subaction == "mark_complete"
  end

  def mark_as_complete
    @evaluation.completed_at = Time.current
    @evaluation.save!

    true
  rescue ActiveRecord::RecordInvalid
    @evaluation.completed_at = nil
    false
  end

  def save_as_draft
    @evaluation.completed_at = nil
    @evaluation.save(validate: false)
  end
end
