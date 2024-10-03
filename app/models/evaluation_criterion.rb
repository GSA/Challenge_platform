# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_criteria
#
#  id                   :bigint           not null, primary key
#  title                :string           not null
#  description          :string           not null
#  points_or_weight     :smallint         not null
#  scoring_type         :integer          default("numeric")
#  option_range_start   :smallint         default(0)
#  option_range_end     :smallint         default(4)
#  option_labels        :json             default([])
#  evaluation_form_id   :bigint           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null

class EvaluationCriterion < ApplicationRecord
  # Associations
  belongs_to :evaluation_form

  # Attributes
  attribute :title, :string
  attribute :description, :string
  attribute :points_or_weight, :integer
  attribute :scoring_type, :integer, default: 0
  attribute :option_range_start, :integer, default: 0
  attribute :option_range_end, :integer, default: 4
  attribute :option_labels, :json, default: -> { [] }
  attribute :evaluation_form_id, :integer

  enum :scoring_type, { numeric: 0, rating: 1, binary: 2 }

  # Validation
  validates :title, :description, :points_or_weight, presence: true
  validates :points_or_weight, numericality: { only_integer: true }
  validates :title,
            uniqueness: { scope: :evaluation_form_id, message: I18n.t("evaluation_criterion_unique_title_in_form") }

  validate :criteria_weights_sum_to_one_hundred

  self.table_name = 'evaluation_criteria'

  private

  def criteria_weights_sum_to_one_hundred
    # TODO: Add validation for criteria weights summing to 100
  end
end
