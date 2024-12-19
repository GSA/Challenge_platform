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
  has_many :evaluations, through: :evaluator_submission_assignments, dependent: :destroy

  # Fields
  attribute :title, :string
  attribute :brief_description, :string
  attribute :description, :string
  attribute :external_url, :string
  attribute :terms_accepted, :boolean, default: nil
  attribute :review_verified, :boolean, default: nil

  # Validations
  validates :title, presence: true

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

  def average_score
    avg = evaluations.average(:total_score)
    score = avg ? avg.round : 0
    [score, score.to_s]
  end

  def self.order_by_average_score(direction)
    direction_sql = direction == :desc ? 'DESC' : 'ASC'

    joins(
      "LEFT JOIN evaluations ON evaluations.submission_id = submissions.id " \
      "AND evaluations.completed_at IS NOT NULL"
    ).
      group('submissions.id').
      order(
        Arel.sql(
          "COALESCE(ROUND(AVG(evaluations.total_score)), 0) #{direction_sql}, " \
          "submissions.id #{direction_sql}"
        )
      )
  end
end
