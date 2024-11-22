# frozen_string_literal: true

class EvaluatorSubmissionAssignment < ApplicationRecord
  include ActiveRecord::Sanitization

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

  STATUS_ORDER = %i[recused unassigned recused_unassigned not_started in_progress completed].freeze

  scope :ordered_by_status, lambda {
    order(
      Arel.sql(
        [
          "CASE evaluator_submission_assignments.status",
          *STATUS_ORDER.map.with_index { |status, index| "WHEN #{statuses[status]} THEN #{index}" },
          "ELSE #{STATUS_ORDER.length} END"
        ].join(" ")
      )
    )
  }
end
