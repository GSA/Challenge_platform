# frozen_string_literal: true

# This service handles evaluator recusal and side effects
class EvaluatorRecusalService
  def initialize(evaluator_submission_assignment)
    @evaluator_submission_assignment = evaluator_submission_assignment
  end

  def call
    return false if @evaluator_submission_assignment.nil?

    ActiveRecord::Base.transaction do
      @evaluator_submission_assignment.update!(status: :recused)
      @evaluator_submission_assignment.evaluation&.destroy!
    end
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    false
  end
end
