# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluations
#
#  id                                 :bigint           not null, primary key
#  user_id                            :bigint           not null
#  evaluation_form_id                 :bigint           not null
#  submission_id                      :bigint           not null
#  evaluator_submission_assignment_id :bigint           not null
#  additional_comments                :text
#  revision_comments                  :text
#  total_score                        :integer
#  completed_at                       :datetime
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
class Evaluation < ApplicationRecord
  belongs_to :user
  belongs_to :evaluation_form
  belongs_to :submission
  belongs_to :evaluator_submission_assignment
  has_many :evaluation_scores, dependent: :destroy

  validates :user_id,
            uniqueness: { scope: [:evaluation_form_id, :submission_id],
                          message: I18n.t("evaluations.unique_user_for_evaluation_form_and_submission_error") }

  validates :evaluator_submission_assignment,
            uniqueness: { message: I18n.t('evaluations.unique_evaluator_submission_assignment') }

  validates :total_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :additional_comments, length: { maximum: 3000 },
                                  allow_nil: true
  validates :revision_comments, length: { maximum: 3000 },
                                allow_nil: true

  validate :user_has_valid_role

  private

  def user_has_valid_role
    return if User::VALID_EVALUATOR_ROLES.include?(user.role)

    errors.add(:user, "must have a valid evaluator role")
  end
end
