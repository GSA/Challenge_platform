# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_scores
#
#  id                      :bigint           not null, primary key
#  evaluation_id           :bigint           not null
#  evaluation_criterion_id :bigint           not null
#  score                   :integer          not null
#  score_override          :integer
#  calculated_score        :decimal
#  comment                 :text
#  comment_override        :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class EvaluationScore < ApplicationRecord
  belongs_to :evaluation
  belongs_to :evaluation_criterion

  validates :evaluation_id, uniqueness: {
    scope: :evaluation_criterion_id,
    message: I18n.t("evaluation_scores.unique_evaluation_for_evaluation_criterion_error")
  }

  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :score, presence: true, if: -> { evaluation.completed_at.present? }
  validates :score_override, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :comment, presence: true, if: -> { evaluation.evaluation_form.comments_required? }
  validates :comment, length: { maximum: 3000 }, allow_nil: true
  validates :comment_override, length: { maximum: 3000 },
                               allow_nil: true

  validate :score_within_criterion_limits

  before_save :set_calculated_score

  def effective_score
    score_override || score
  end

  def effective_comment
    comment_override || comment
  end

  private

  # TODO: Should these error messages be more generic instead of specific values
  # Ex. less than or equal to criterion points or weight
  def score_within_criterion_limits
    case evaluation_criterion.scoring_type
    when 'numeric'
      validate_numeric_score
    when 'rating', 'binary'
      validate_range_score
    else
      errors.add(:base, "Invalid scoring type for criterion")
    end
  end

  def validate_numeric_score
    max_score = evaluation_criterion.points_or_weight

    if score && score > max_score
      errors.add(:score, "must be less than or equal to #{max_score}")
    end

    # This is written differently than above because of rubocop
    return unless score_override && score_override > max_score

    errors.add(:score_override, "must be less than or equal to #{max_score}")
  end

  def validate_range_score
    range_start = evaluation_criterion.option_range_start
    range_end = evaluation_criterion.option_range_end
    valid_range = (range_start..range_end)

    if score && valid_range.exclude?(score)
      errors.add(:score, "must be within the range #{range_start} to #{range_end}")
    end

    # This is written differently than above because of rubocop
    return unless score_override && valid_range.exclude?(score_override)

    errors.add(:score_override, "must be within the range #{range_start} to #{range_end}")
  end

  def set_calculated_score
    return if effective_score.blank?

    self.calculated_score = calculate_score
  end

  def calculate_score
    points = evaluation_criterion.points_or_weight

    case evaluation_criterion.scoring_type
    when "binary"
      effective_score == 1 ? points : 0
    when "numeric"
      # Another way to ensure the calculated score is at most the max points for the criterion
      [effective_score, points].min
    when "rating"
      best_option = evaluation_criterion.option_range_end
      (points / best_option) * effective_score
    else
      0
    end.round(2)
  end
end
