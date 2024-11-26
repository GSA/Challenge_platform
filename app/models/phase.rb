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
  has_many :submissions, dependent: :destroy
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
end
