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
  has_many :evaluation_criteria, through: :evaluation_form
  accepts_nested_attributes_for :evaluation_scores

  validates_associated :evaluation_scores

  validates :user_id,
            uniqueness: { scope: [:evaluation_form_id, :submission_id],
                          message: I18n.t("evaluations.unique_user_for_evaluation_form_and_submission_error") }

  validates :evaluator_submission_assignment,
            uniqueness: { message: I18n.t('evaluations.unique_evaluator_submission_assignment') }

  validates :total_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :additional_comments,
            length: { maximum: 3000,
                      message: I18n.t("form.errors.too_long", field_name: "Additional comments", max_length: 3000) },
            allow_nil: true
  validates :revision_comments,
            length: { maximum: 3000,
                      message: I18n.t("form.errors.too_long", field_name: "Revision comments", max_length: 3000) },
            allow_nil: true

  validate :user_has_valid_role

  before_save :ensure_all_scores_exist
  before_save :calculate_total_score
  after_create :update_submission_evaluation_status
  after_update :update_submission_evaluation_status, if: -> { saved_change_to_completed_at? }
  after_destroy :update_submission_evaluation_status

  ERROR_ORDER = %i[evaluation_scores].freeze

  def calculated_total_score(use_evaluator_scores: false)
    total = use_evaluator_scores ? calculate_score_with_evaluator_scores : total_score

    return nil if total.nil?

    format_total(total)
  end

  def revisable?
    submission.selected?
  end

  def revised?
    evaluation_scores.any? { |score| score.score_override.present? }
  end

  private

  def user_has_valid_role
    return if User::VALID_EVALUATOR_ROLES.include?(user.role)

    errors.add(:user, "must have a valid evaluator role")
  end

  def ensure_all_scores_exist
    missing_criteria =
      evaluation_form.evaluation_criteria.where.not(id: evaluation_scores.map(&:evaluation_criterion_id))
    missing_criteria.each do |criterion|
      evaluation_scores.build(evaluation_criterion: criterion)
    end
  end

  def calculate_total_score
    return if evaluation_scores.blank?

    # Ensure all scores have calculated values before summing
    self.total_score = if evaluation_scores.any? { |score| score.calculated_score.blank? }
                         nil
                       else
                         evaluation_scores.sum(&:calculated_score).round(2)
                       end
  end

  def update_submission_evaluation_status
    EvaluationStatusService.update_evaluation_status(submission)
  end

  def calculate_score_with_evaluator_scores
    evaluation_scores.each do |score|
      calculated_score = score.calculated_score(score.score)
      return nil if calculated_score.nil?
    end

    evaluation_scores.sum { |score| score.calculated_score(score.score) }
  end

  def format_total(total)
    total.to_f.round(2).to_s.sub(/\.0+$/, '') unless total.nil?
  end
end
