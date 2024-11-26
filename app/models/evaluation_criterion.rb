# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_criteria
#
#  id                 :bigint           not null, primary key
#  evaluation_form_id :bigint           not null
#  title              :string           not null
#  description        :string           not null
#  points_or_weight   :integer          not null
#  scoring_type       :integer          not null
#  option_range_start :integer
#  option_range_end   :integer
#  option_labels      :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
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
  validates :title, length: { maximum: 150 }
  validates :description, length: { maximum: 1000 }
  validates :points_or_weight, numericality: { only_integer: true }
end
