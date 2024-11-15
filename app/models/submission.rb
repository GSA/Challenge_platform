# frozen_string_literal: true

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
  def eligible_for_evaluation?
    selected? or winner?
  end

  def selected_to_advance?
    winner?
  end
end
