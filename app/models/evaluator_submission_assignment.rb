# frozen_string_literal: true

class EvaluatorSubmissionAssignment < ApplicationRecord
  belongs_to :submission
  belongs_to :evaluator, class_name: "User", foreign_key: :user_id, inverse_of: :assigned_submissions

  has_one :phase, through: :submission

  enum :status, {
    assigned: 0,
    unassigned: 1,
    recused: 2,
    not_started: 3,
    in_progress: 4,
    completed: 5,
    recused_unassigned: 6
  }

  STATUS_ORDER = [:recused, :unassigned, :recused_unassigned, :not_started, :in_progress, :completed]

  scope :ordered_by_status, -> {
    order(Arel.sql(
      "CASE " +
      STATUS_ORDER.map.with_index { |status, index|
        "WHEN evaluator_submission_assignments.status = #{statuses[status]} THEN #{index + 1}"
      }.join(" ") +
      " ELSE #{STATUS_ORDER.length + 1} END"
    ))
  }
end
