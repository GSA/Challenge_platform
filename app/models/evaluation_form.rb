# frozen_string_literal: true

# == Schema Information
#
# Table name: evaluation_forms
#
#  id                :bigint           not null, primary key
#  instructions      :string           not null
#  comments_required :boolean          default(FALSE)
#  scale_type        :string           not null
#  closing_date      :date             not null
#  challenge_id      :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  phase_id          :bigint           not null
#
class EvaluationForm < ApplicationRecord
  belongs_to :challenge
  belongs_to :phase, optional: true # Disables default must exist error message
  has_many :evaluation_criteria, lambda {
    order(:created_at)
  }, class_name: 'EvaluationCriterion', dependent: :destroy, inverse_of: :evaluation_form
  accepts_nested_attributes_for :evaluation_criteria, allow_destroy: true

  enum :scale_type, { point: "point", weight: "weight" }, type: "string"

  scope :by_user, lambda { |user|
    joins(challenge: :challenge_manager_users).
      where(challenge_manager_users: { id: user.id })
  }

  validates :instructions, presence: { message: I18n.t("form.errors.input", field_name: "evaluation instructions") }
  validates :scale_type, presence: { message: I18n.t("form.errors.radio", field_name: "scoring type") }
  validates :closing_date, presence: { message: I18n.t("form.errors.input", field_name: "closing date") }

  # Adds custom error message for phase presence failure instead of default from above
  validates :phase, presence: { message: I18n.t("form.errors.select", field_name: :phase) }
  validates :phase_id, uniqueness: true

  validate :criteria_weights_must_sum_to_one_hundred
  validate :validate_unique_criteria_titles

  ERROR_ORDER = %i[instructions scale_type base evaluation_criteria closing_date].freeze

  def weighted_scoring?
    scale_type == "weight"
  end

  def point_scoring?
    scale_type == "point"
  end

  private

  def validate_unique_criteria_titles
    duplicate_titles = find_duplicate_titles

    add_criteria_title_errors(duplicate_titles) unless duplicate_titles.empty?
  end

  def find_duplicate_titles
    current_criteria_titles = evaluation_criteria.reject(&:marked_for_destruction?).map(&:title)
    current_criteria_titles.select { |title| current_criteria_titles.count(title) > 1 }.uniq
  end

  def add_criteria_title_errors(duplicate_titles)
    criteria = evaluation_criteria.
      reject(&:marked_for_destruction?).
      select { |c| duplicate_titles.include?(c.title) }.
      reject { |c| c.errors.added?(:title, I18n.t("evaluation_criteria.errors.duplicate_title")) }

    criteria.each { |c| c.errors.add(:title, I18n.t("evaluation_criteria.errors.duplicate_title")) }

    errors.add(:base, I18n.t("evaluation_form.errors.criteria_unique_titles"))
  end

  def criteria_weights_must_sum_to_one_hundred
    return unless weighted_scoring? && total_criteria_weight != 100

    add_weight_errors
  end

  def total_criteria_weight
    evaluation_criteria.reject(&:marked_for_destruction?).sum { |criteria| criteria.points_or_weight.to_i }
  end

  def add_weight_errors
    evaluation_criteria.reject(&:marked_for_destruction?).each do |criteria|
      criteria.errors.add(:points_or_weight, I18n.t("evaluation_criteria.errors.must_sum_to_100"))
    end

    errors.add(:base, I18n.t("evaluation_form.errors.criteria_weight_total"))
  end
end
