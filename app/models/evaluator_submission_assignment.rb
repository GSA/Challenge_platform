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
    not_started: 3,
    in_progress: 4,
    completed: 5,
    recused_unassigned: 6
  }

  scope :ordered_by_status, lambda {
    order(
      Arel.sql(
        "CASE evaluator_submission_assignments.status
          WHEN #{ActiveRecord::Base.connection.quote(statuses[:recused])} THEN 0
          WHEN #{ActiveRecord::Base.connection.quote(statuses[:unassigned])} THEN 1
          WHEN #{ActiveRecord::Base.connection.quote(statuses[:recused_unassigned])} THEN 2
          WHEN #{ActiveRecord::Base.connection.quote(statuses[:not_started])} THEN 3
          WHEN #{ActiveRecord::Base.connection.quote(statuses[:in_progress])} THEN 4
          WHEN #{ActiveRecord::Base.connection.quote(statuses[:completed])} THEN 5
          ELSE 6
        END"
      )
    )
  }
end
