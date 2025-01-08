# frozen_string_literal: true

# View helpers for calculating evaluation & submission details.
module EvaluationsHelper
  Score = Struct.new(:raw_score, :formatted_score, :display_score)

  # individual evaluator score
  def evaluator_score(assignment)
    score = display_score(assignment)
    return Score.new(0, "0", "N/A") if score == 'N/A'

    Score.new(score, score.to_s, score.to_s)
  end

  def average_score(submission)
    score = submission.average_score
    return Score.new(0, "0", "N/A") if score.zero?

    Score.new(score, score.to_s, score.to_s)
  end
end
