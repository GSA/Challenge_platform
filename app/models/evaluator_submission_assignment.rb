# frozen_string_literal: true

class EvaluatorSubmissionAssignment < ApplicationRecord
  belongs_to :submission
  belongs_to :evaluator, class_name: "User", foreign_key: :user_id, inverse_of: :assigned_submissions

  enum :status, { assigned: 0, unassigned: 1, recused: 2 }
end
