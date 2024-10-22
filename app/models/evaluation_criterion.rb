# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_criteria
#
#  id                   :bigint           not null, primary key
#  title                :string           not null
#  description          :string           not null
#  points_or_weight     :smallint         not null
#  scoring_type         :integer          not null
#  option_range_start   :smallint
#  option_range_end     :smallint
#  option_labels        :json             default([])
#  evaluation_form_id   :bigint           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null

class EvaluationCriterion < ApplicationRecord
  self.table_name = 'evaluation_criteria'

  # Associations
  belongs_to :evaluation_form

  # Attributes
  attribute :title, :string
  attribute :description, :string
  attribute :points_or_weight, :integer
  enum :scoring_type, { numeric: 0, rating: 1, binary: 2 }
  attribute :option_range_start, :integer
  attribute :option_range_end, :integer
  attribute :option_labels, :json, default: -> { {} }
  attribute :evaluation_form_id, :integer

  # Validations
  validates :title, :description, :points_or_weight, presence: true
  validates :points_or_weight, numericality: { only_integer: true }
end
