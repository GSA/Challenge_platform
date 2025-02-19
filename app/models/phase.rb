# frozen_string_literal: true

# == Schema Information
#
# Table name: phases
#
#  id                     :bigint           not null, primary key
#  challenge_id           :bigint           not null
#  uuid                   :uuid             not null
#  title                  :string(255)
#  start_date             :datetime
#  end_date               :datetime
#  open_to_submissions    :boolean
#  judging_criteria       :text
#  judging_criteria_delta :text
#  how_to_enter           :text
#  how_to_enter_delta     :text
#  inserted_at            :datetime         not null
#  updated_at             :datetime         not null
#  submissions_count      :integer          default(0), not null
#
class Phase < ApplicationRecord
  belongs_to :challenge
  # More relations from phoenix app
  has_many :all_submissions, class_name: "Submission", dependent: :destroy
  has_many :submissions, lambda {
    where(status: "submitted").where(deleted_at: nil)
  }, inverse_of: :phase, dependent: :destroy
  has_many :evaluator_submission_assignments, through: :submissions
  has_one :evaluation_form, dependent: :destroy
  # has_one :winner, class_name: 'PhaseWinner'
  has_many :evaluator_invitations, dependent: :destroy
  has_many :challenge_phases_evaluators, dependent: :destroy
  has_many :evaluators, through: :challenge_phases_evaluators, source: :user

  # Attributes
  attribute :uuid, :uuid
  attribute :title, :string
  attribute :start_date, :datetime
  attribute :end_date, :datetime
  attribute :open_to_submissions, :boolean
  attribute :judging_criteria, :text
  attribute :how_to_enter, :text
  attribute :challenge_uuid, :uuid

  # Virtual fields
  attribute :judging_criteria_length, :integer, default: 0
  attribute :how_to_enter_length, :integer, default: 0
  attribute :delete_phase, :boolean, default: false

  # Validations
  validates :title, :start_date, :end_date, presence: true

  def evaluation_status
    eligible_for_evaluation_exists = submissions.eligible_for_evaluation.exists?
    in_progress_or_completed_exists = submissions.eligible_for_evaluation.where(evaluation_status: [:in_progress, :completed]).exists?
    in_progress_exists = submissions.eligible_for_evaluation.where(evaluation_status: :in_progress).exists?
    if !eligible_for_evaluation_exists || !in_progress_or_completed_exists
      # no submissions are eligible for evaluation, or if they do they are all currently not_started
      :not_started
    elsif !in_progress_exists
      :completed
    else
      :in_progress
    end
  end
end
