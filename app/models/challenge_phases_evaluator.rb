# frozen_string_literal: true

# == Schema Information
#
# Table name: challenge_phases_evaluators
#
#  id           :bigint           not null, primary key
#  challenge_id :bigint           not null
#  phase_id     :bigint           not null
#  user_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class ChallengePhasesEvaluator < ApplicationRecord
  belongs_to :challenge
  belongs_to :phase
  belongs_to :user

  validate :user_has_valid_role, if: -> { user.present? }

  private

  def user_has_valid_role
    unless User::VALID_EVALUATOR_ROLES.include?(user.role)
      errors.add(:user, "must have a valid evaluator role")
    end
  end
end
