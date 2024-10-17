# frozen_string_literal: true

class Submission < ApplicationRecord
  # Associations
  belongs_to :submitter, class_name: 'User'
  belongs_to :challenge
  belongs_to :phase
  belongs_to :manager, class_name: 'User'

  # Fields
  attribute :title, :string
  attribute :brief_description, :string
  attribute :description, :string
  attribute :description_delta, :string
  attribute :external_url, :string
  attribute :status, :string
  attribute :judging_status, :string, default: "not_selected"
  attribute :terms_accepted, :boolean, default: nil
  attribute :review_verified, :boolean, default: nil


  # Validations
  validates :title, :start_date, :end_date, presence: true
end
