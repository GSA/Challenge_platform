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
  validates :title, :description, :points_or_weight, presence: { message: lambda { |obj, data|
    I18n.t("form.errors.input", field_name: obj.class.human_attribute_name(data[:attribute]).downcase)
  } }
  validates :scoring_type, presence: { message: lambda { |obj, data|
    I18n.t("form.errors.select", field_name: "scale type")
  } }
  validates :title,
            length: { maximum: 150, message: I18n.t("form.errors.too_long", field_name: "Title", max_length: 150) }
  validates :description,
            length: { maximum: 1000,
                      message: I18n.t("form.errors.too_long", field_name: "Description", max_length: 1000) }
  validates :points_or_weight,
            numericality: { only_integer: true,
                            message: I18n.t("form.errors.not_an_integer", field_name: "Points or weight") }

  validate :validate_option_labels_not_blank, if: -> { rating? || binary? }

  ERROR_ORDER = %i[title description points_or_weight scoring_type option_labels].freeze

  private

  def validate_option_labels_not_blank
    return unless option_labels.is_a?(Hash)

    has_blank_labels = false

    option_labels.each do |key, value|
      if value.blank?
        errors.add("option_labels_#{key}", I18n.t("form.errors.input", field_name: "option label #{key}"))
        has_blank_labels = true
      end
    end

    errors.add(:option_labels, "Missing option labels") if has_blank_labels
  end
end
