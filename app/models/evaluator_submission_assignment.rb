# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluator_submission_assignments
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  submission_id :bigint           not null
#  status        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class EvaluatorSubmissionAssignment < ApplicationRecord
  ORDER_VALUES = {
    recused: 0,
    unassigned: 1,
    recused_unassigned: 2,
    not_started: 3,
    in_progress: 4,
    completed: 5
  }.freeze

  # Associations
  belongs_to :submission
  belongs_to :evaluator, class_name: "User", foreign_key: :user_id, inverse_of: :assigned_submissions
  has_one :evaluation, dependent: :destroy

  has_one :phase, through: :submission

  validates :submission_id, uniqueness: {
    scope: :user_id,
    message: I18n.t("evaluator_submission_assignments.uniqueness_error")
  }

  enum :status, {
    assigned: 0,
    unassigned: 1,
    recused: 2,
    recused_unassigned: 3
  }

  def self.ordered_by_status
    includes(:evaluation).
      select('evaluator_submission_assignments.*, evaluations.id AS evaluation_id, evaluations.completed_at').
      left_joins(:evaluation).
      to_a.
      sort_by { |assignment| ORDER_VALUES[assignment.evaluation_status] }
  end

  def evaluation_status
    return :recused if recused?
    return :unassigned if unassigned?
    return :recused_unassigned if recused_unassigned?
    return assigned_evaluation_status if assigned?

    status&.to_sym
  end

  private

  def assigned_evaluation_status
    if evaluation&.completed_at.present?
      :completed
    elsif evaluation.present?
      :in_progress
    else
      :not_started
    end
  end
end
