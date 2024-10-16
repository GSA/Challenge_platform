# frozen_string_literal: true

# == Schema Information
#
# Table name: phases
#
#  id                     :bigint           not null, primary key
#  uuid                   :uuid             not null, default: -> { "gen_random_uuid()" }
#  title                  :string
#  start_date             :datetime
#  end_date               :datetime
#  open_to_submissions     :boolean
#  judging_criteria        :string
#  judging_criteria_delta  :string
#  judging_criteria_length :integer          virtual
#  how_to_enter            :string
#  how_to_enter_delta      :string
#  how_to_enter_length     :integer          virtual
#  delete_phase            :boolean          virtual
#  challenge_id            :bigint           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Phase < ApplicationRecord
  belongs_to :challenge
  # More relations from phoenix app
  # has_many :submissions
  # has_one :winner, class_name: 'PhaseWinner'

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
