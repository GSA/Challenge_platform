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
  enum :evaluation_status, { not_started: "not_started", in_progress: "in_progress", completed: "completed" }

  # Associations
  belongs_to :challenge
  belongs_to :phase, counter_cache: true
  belongs_to :submitter, class_name: 'User'
  has_many :evaluator_submission_assignments, dependent: :destroy
  has_many :evaluators, through: :evaluator_submission_assignments, class_name: "User"
  has_many :evaluations, dependent: :destroy
  has_many :documents, dependent: :destroy

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
    by_user_role =
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
    by_user_role.where(deleted_at: nil)
  }
  scope :eligible_for_evaluation, -> { where(judging_status: [:selected, :winner]) }

  scope :order_by_assignee_count, lambda { |direction|
    direction_sql = direction == :desc ? 'DESC' : 'ASC'
    join_sql = <<-JOIN_SQL
      LEFT OUTER JOIN evaluator_submission_assignments
      ON submissions.id = evaluator_submission_assignments.submission_id
      AND evaluator_submission_assignments.status in (0, 2)
    JOIN_SQL
    eligible_for_evaluation.
      joins(join_sql).
      group("submissions.id").
      select("submissions.*, count(evaluator_submission_assignments.id) as assignee_count").
      order("assignee_count #{direction_sql}")
  }

  scope :order_by_average_score, lambda { |direction|
    direction_sql = direction == :desc ? 'DESC' : 'ASC'

    where(evaluation_status: :completed).
      joins(
        "LEFT JOIN evaluations ON evaluations.submission_id = submissions.id"
      ).
      group('submissions.id').
      order(
        Arel.sql(
          "COALESCE(AVG(evaluations.total_score), 0) #{direction_sql}, " \
          "submissions.id #{direction_sql}"
        )
      )
  }

  # Phase evaluators not currently assigned or recused on the submission
  def available_evaluators
    unavailable_evaluators = evaluators.where.not("evaluator_submission_assignments.status" => "unassigned")
    phase.evaluators.where.not(id: unavailable_evaluators).where(role: "evaluator", status: "active")
  end

  def eligible_for_evaluation?
    selected? or winner?
  end

  def average_score
    avg = evaluations.joins(:evaluator_submission_assignment).
      where(evaluator_submission_assignments: { status: :assigned }).
      where.not(completed_at: nil).
      average(:total_score)

    avg ? avg.round : 0
  end

  def selected_to_advance?
    winner?
  end

  def evaluators_assigned?
    evaluator_submission_assignments.exists?(status: [:assigned, :recused])
  end

  def evaluations_missing_or_incomplete?
    !eligible_for_evaluation? || evaluator_submission_assignments.assigned.empty? || !all_evaluations_completed?
  end

  def all_evaluations_completed?
    evaluator_submission_assignments.assigned.
      all? { |assignment| assignment.evaluation_status == :completed }
  end

  private

  def can_be_selected_to_advance
    return unless evaluations_missing_or_incomplete?

    errors.add(:judging_status, "can't be selected to advance until all evaluations are complete")
  end

  def can_be_ineligible_for_evaluation
    return unless evaluators_assigned?

    errors.add(:judging_status, "must remain eligible for evaluation when evaluators are assigned")
  end
end
