# frozen_string_literal: true

class Submission < ApplicationRecord
  enum :status, { draft: 0, submitted: 1 }
  enum :judging_status, { not_selected: 0, selected: 1, qualified: 2, winner: 3 }

  # Associations
  belongs_to :submitter, class_name: 'User'
  belongs_to :challenge
  belongs_to :phase
  belongs_to :manager, class_name: 'User'

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
