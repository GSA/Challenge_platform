# frozen_string_literal: true

# == Schema Information
#
# Table name: submissions
#
#  id                      :bigint           not null, primary key
#  submitter_id            :bigint           not null
#  challenge_id            :bigint           not null
#  title                   :string(255)
#  brief_description       :text
#  description             :text
#  external_url            :string(255)
#  status                  :string(255)
#  deleted_at              :datetime
#  inserted_at             :datetime         not null
#  updated_at              :datetime         not null
#  phase_id                :bigint           not null
#  judging_status          :string(255)      default("not_selected")
#  manager_id              :bigint
#  terms_accepted          :boolean
#  review_verified         :boolean
#  description_delta       :text
#  brief_description_delta :text
#  pdf_reference           :string(255)
#  comments                :text
#
class Submission < ApplicationRecord
  enum :status, { draft: "draft", submitted: "submitted" }
  enum :judging_status, { not_selected: "not_selected", selected: "selected", qualified: "qualified", winner: "winner" }

  # Associations
  belongs_to :challenge
  belongs_to :phase, counter_cache: true
  belongs_to :submitter, class_name: 'User'
  belongs_to :manager, class_name: 'User'
  has_many :evaluator_submission_assignments, dependent: :destroy
  has_many :evaluators, through: :evaluator_submission_assignments, class_name: "User"
  has_many :evaluations, dependent: :destroy

  # Fields
  attribute :title, :string
  attribute :brief_description, :string
  attribute :description, :string
  attribute :external_url, :string
  attribute :terms_accepted, :boolean, default: nil
  attribute :review_verified, :boolean, default: nil

  # Validations
  validates :title, presence: true
  validate :can_be_selected_to_advance,
           if: -> { judging_status_change == %w[selected winner] }
  validate :can_be_ineligible_for_evaluation,
           if: -> { judging_status_change == %w[selected not_selected] }

  scope :by_user, lambda { |user|
    case user.role
    when 'challenge_manager'
      where(challenge: user.challenge_manager_challenges)
    when 'evaluator'
      joins(:evaluators).where(evaluators: { id: user.id })
    when 'solver'
      where(submitter: user)
    else
      none
    end
  }
  scope :eligible_for_evaluation, -> { where(judging_status: [:selected, :winner]) }

  def eligible_for_evaluation?
    selected? or winner?
  end

  def selected_to_advance?
    winner?
  end

  def eligibility_deselection_disabled?
    evaluator_submission_assignments.exists?(status: [:assigned, :recused])
  end

  def advancement_checkbox_disabled?
    !eligible_for_evaluation? || !all_evaluations_completed? || evaluators.empty?
  end

  private

  def all_evaluations_completed?
    evaluator_submission_assignments.
      includes(:evaluation).
      all? { |assignment| assignment.evaluation_status == :completed }
  end

  def can_be_selected_to_advance
    unless judging_status_was == 'selected'
      errors.add(:judging_status, "can't be selected to advance when not eligible for evaluation")
      return
    end

    return unless advancement_checkbox_disabled?

    errors.add(:judging_status, "can't be selected to advance until all evaluations are complete")
  end

  def can_be_ineligible_for_evaluation
    return unless eligibility_deselection_disabled?

    errors.add(:judging_status, "can't deselect evaluation eligibility when there are evaluators assigned")
  end
end
