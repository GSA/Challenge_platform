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
  belongs_to :submission
  belongs_to :evaluator, class_name: "User", foreign_key: :user_id, inverse_of: :assigned_submissions
  has_one :evaluation, dependent: :destroy

  has_one :phase, through: :submission

  enum :status, {
    assigned: 0,
    unassigned: 1,
    recused: 2,
    recused_unassigned: 3
  }

  def evaluation_status
    if assigned?
      if evaluation.nil?
        :not_started
      elsif evaluation.completed_at.nil?
        :in_progress
      else
        :completed
      end
    else
      status.to_sym
    end
  end

  ORDER_VALUES = {
    recused: 0,
    unassigned: 1,
    recused_unassigned: 2,
    not_started: 3,
    in_progress: 4,
    completed: 5
  }.freeze

  def ordering_priority
    case evaluation_status
    when :recused then ORDER_VALUES[:recused]
    when :unassigned then ORDER_VALUES[:unassigned]
    when :recused_unassigned then ORDER_VALUES[:recused_unassigned]
    when :not_started then ORDER_VALUES[:not_started]
    when :in_progress then ORDER_VALUES[:in_progress]
    when :completed then ORDER_VALUES[:completed]
    end
  end

  scope :ordered_by_status, lambda {
    select('evaluator_submission_assignments.*, evaluations.id AS evaluation_id, evaluations.completed_at').
      left_joins(:evaluation).
      to_a.
      sort_by(&:ordering_priority)
  }
end
