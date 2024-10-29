# frozen_string_literal: true

class Submission < ApplicationRecord
  enum :status, { draft: "draft", submitted: "submitted" }
  enum :judging_status, { not_selected: "not_selected", selected: "selected", qualified: "qualified", winner: "winner" }

  # Associations
  belongs_to :submitter, class_name: 'User'
  belongs_to :challenge
  belongs_to :phase
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
end
