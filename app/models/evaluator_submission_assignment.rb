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
end
