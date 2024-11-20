# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluations
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint           not null
#  evaluation_form_id    :bigint           not null
#  status                :integer          default("not_started"), not null
#  total_score           :integer          default(nil)
#  additional_comments   :text
#  revision_comments     :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class Evaluation < ApplicationRecord
  belongs_to :user
  belongs_to :evaluation_form
  has_many :evaluation_scores, dependent: :destroy

  enum :status, {
    not_started: 0,
    recused: 1,
    in_progress: 2,
    completed: 3
  }

  validates :total_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :additional_comments, length: { maximum: 3000, message: "cannot exceed 3000 characters" },
                                  allow_nil: true
  validates :revision_comments, length: { maximum: 3000, message: "cannot exceed 3000 characters" },
                                allow_nil: true

  validate :user_has_valid_role

  private

  def user_has_valid_role
    return if User::VALID_EVALUATOR_ROLES.include?(user.role)

    errors.add(:user, "must have a valid evaluator role")
  end
end
