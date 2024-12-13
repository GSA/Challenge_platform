# frozen_string_literal: true

# View helpers for calculating evaluation & submission details.
module EvaluationsHelper
  Score = Struct.new(:raw_score, :formatted_score, :display_score)

  # individual evaluator score
  def evaluator_score(assignment)
    score = assignment.evaluation&.total_score

    unless assignment.evaluation_status == :completed && score
      return Score.new(0, "0", "N/A")
    end

    Score.new(score, score.to_s, score.to_s)
  end

  def average_score(submission)
    completed_evaluations = submission.evaluations.where.not(completed_at: nil)

    unless completed_evaluations.any?
      return Score.new(0, "0", "N/A")
    end

    avg = completed_evaluations.average(:total_score)
    score = avg ? avg.round : 0
    Score.new(score, score.to_s, score.to_s)
  end
end
