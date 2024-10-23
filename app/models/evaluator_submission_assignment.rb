class EvaluatorSubmissionAssignment < ApplicationRecord
  belongs_to :submission
  belongs_to :evaluator, class_name: "User"

  enum :status, { assigned: 0, unassigned: 1, recused: 2 }
end